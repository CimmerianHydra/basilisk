extends BattleAction
class_name Skirmish
## SKIRMISH: attack with a single, non-SUPERHEAVY weapon.
##
## The action is now a rules-blind script: pay the cost, offer only weapons
## that can actually fire, route the profile's TargetingQuery to the right
## picker, then resolve once per target in the resulting TargetSet.
##
## The resolution loop below is TRANSITIONAL: in milestone 2 it is extracted
## into an AttackFlow that BARRAGE, OVERWATCH, and IMPROVISED ATTACK reuse,
## with tag behavior moving out of the inline branches into WeaponEffects
## invoked at each hook.
 
 
func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
 
	var payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(payment)
	await BattleEngine.resolve_event(payment)
 
	# --- weapon: only what can legally fire right now is offered ------------
	var usable: Array = _unit._weapons.filter(
			func(w: Weapon) -> bool: return w.usable_in_skirmish(_unit))
	if usable.is_empty():
		print("Unit %s has no usable weapon." % _unit.display_name())
		return
 
	var weapon: Weapon = await BattleEngine.ask(_unit._controller, usable,
			"Choose weapon for Skirmish:", Choice.Kind.PICK_WEAPON, {"actor": _unit})
 
	# --- profile: almost always one; the Siege Cannon asks -------------------
	var profiles := weapon.usable_profiles(_unit)
	var profile: WeaponProfile = profiles[0]
	if profiles.size() > 1:
		profile = await BattleEngine.ask(_unit._controller, profiles,
				"Choose fire mode:", Choice.Kind.GENERIC, {"actor": _unit})
 
	# --- targeting ------------------------------------------------------------
	var query := TargetingQuery.build(_unit, profile)
	var targets: TargetSet = await _acquire_targets(query)
	if targets == null or targets.units.is_empty():
		# TODO: gate this BEFORE paying the quick action (offer only weapons
		# with candidates), so a dead-end pick doesn't waste the turn.
		print("No valid targets.")
		return
 
	# --- resolution (transitional; becomes AttackFlow) -------------------------
	# Pattern rule: a separate attack roll per target, but damage is rolled ONCE
	# for the whole attack. Every packet is rolled twice up front so per-target
	# crits can take the higher result per source without a second shared roll.
	var damage_rolls := _roll_damage(profile)
 
	for target: Unit in targets.units:
		var atk := AttackRollEvent.new(_unit, target)
		atk.weapon = weapon.definition
		# Accuracy/difficulty contributions (cover measured from targets.origin
		# for BLAST, engagement, LOCK ON) migrate into staged listeners in
		# milestone 2; the profile's own tags are applied inline for now.
		if profile.has_tag(WeaponProfile.WeaponTag.ACCURATE):
			atk.accuracy += 1
		if profile.has_tag(WeaponProfile.WeaponTag.INACCURATE):
			atk.difficulty += 1
		await BattleEngine.stage_event(atk)
		await BattleEngine.resolve_event(atk)
 
		# SMART attacks "use the target's E-DEFENSE instead of EVASION".
		var defense: int = target.get_e_defense() if profile.targets_e_defense() else target.get_evasion()
		var hit := atk.total >= defense
		var crit := hit and atk.total >= 20
 
		if hit:
			if crit:
				print("  CRIT vs %s!" % target.display_name())
			for entry: Dictionary in damage_rolls:
				var amount: int = entry.crit if crit else entry.normal
				# TODO(bonus damage): bonus packets are halved when
				# targets.multi_target(); base packets never are.
				target.apply_damage(amount, (entry.packet as DamagePacket).type)
			# Milestone 2: on-hit riders run here as WeaponEffects — KNOCKBACK
			# (pushed away from targets.origin), Burn, save-or-status, and
			# on-crit extras after them.
		else:
			# RELIABLE X "always does X damage, even if it misses" — it inherits
			# AP and the base damage type, but not on-hit riders.
			var reliable := profile.tag_value(WeaponProfile.WeaponTag.RELIABLE)
			if reliable > 0 and not profile.damage_packets.is_empty():
				target.apply_damage(reliable, profile.damage_packets[0].type)
			else:
				print("  Miss vs %s." % target.display_name())
 
	weapon.consume_shot(profile) # If the weapon has the LOADING tag, it consumes the shot.
	# TODO(mounts): "you may also attack with a different AUXILIARY weapon on
	# the same mount" — a second, no-bonus-damage pass once mounts exist.
	# TODO(milestone 2): HEAT_SELF applies here, hit or miss.
 
 
## Routes the query to the matching picker and returns the normalized set.
## null means the pick had no legal options.
func _acquire_targets(query: TargetingQuery) -> TargetSet:
	match query.pick_kind():
		TargetingQuery.PickKind.PICK_UNIT:
			var candidates := query.candidate_units()
			if candidates.is_empty():
				return null
			var picked: Unit = await BattleEngine.ask(_unit._controller, candidates,
					"Choose target:", Choice.Kind.PICK_TARGET, {"actor": _unit})
			return query.expand(picked)
 
		TargetingQuery.PickKind.PICK_ANCHOR:
			var anchors := query.candidate_anchors()
			if anchors.is_empty():
				return null
			# Footprints ride along in ctx exactly like `paths` does for
			# PICK_MOVE: hover an anchor, preview its area and affected units.
			var footprints := {}
			for anchor: Vector2i in anchors:
				footprints[anchor] = query.footprint(anchor)
			var chosen: Vector2i = await BattleEngine.ask(_unit._controller, anchors,
					"Choose where to aim:", Choice.Kind.PICK_AOE_ANCHOR,
					{"actor": _unit, "footprints": footprints})
			return query.expand(chosen)
 
		_:
			# BURST: nothing to pick; the footprint is fixed on the user.
			return query.expand(_unit._position)
 
 
## Rolls every packet twice up front: normal targets consume roll A, crit
## targets max(A, B) — the book's "roll all damage dice twice, keep the highest
## result from each source" without re-rolling shared damage per target.
## OVERKILL's reroll-1s-for-heat policy will live here too, so the whole dice
## policy has exactly one home (a DamageRoller, in milestone 2).
func _roll_damage(profile: WeaponProfile) -> Array[Dictionary]:
	var rolls: Array[Dictionary] = []
	for packet: DamagePacket in profile.damage_packets:
		var a := packet.roll()
		var b := packet.roll()
		rolls.append({"packet": packet, "normal": a, "crit": maxi(a, b)})
	return rolls
 
 
func display_name() -> String: return "Skirmish"
