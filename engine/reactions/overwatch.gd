extends Reaction
class_name Overwatch

var _unit : Unit

func _init(unit : Unit) -> void:
	_unit = unit

func _on_event(event : BattleEvent) -> void:
	if event is VoluntaryMoveEvent:
		# Exclude allies and self
		if event.mover._faction == _unit._faction: return
		
		var distance = HexGrid.distance(_unit._position, event.mover._position)
		
		# Check if there's a weapon with a profile that can be used for this overwatch
		var usable_weapons = []
		for w in _unit._weapons:
			if not w.usable_in_skirmish(_unit): continue
			var profiles = w.usable_profiles(_unit)
			for w_p in profiles:
				if w_p.threat >= distance: usable_weapons.append(w); break
		
		# If not, we return
		if usable_weapons.is_empty(): return
		
		# If yes, we ask
		var take_reaction: bool = await BattleEngine.ask(_unit._controller, [true, false],
			"Do you want to Overwatch?", Choice.Kind.CONFIRM, {"actor": _unit})
		if not take_reaction: return
		
		
		# --- weapon: only what can legally fire right now is offered ------------
		var weapon: Weapon = await BattleEngine.ask(_unit._controller, usable_weapons,
				"Choose weapon for Skirmish:", Choice.Kind.PICK_WEAPON, {"actor": _unit})
		
		
		# --- profile: almost always one; need to filter out usable ones ---------
		var weapon_profiles := weapon.usable_profiles(_unit)\
			.filter(func(p : WeaponProfile): return p.threat >= distance)
		var profile: WeaponProfile = weapon_profiles[0]
		if weapon_profiles.size() > 1:
			profile = await BattleEngine.ask(_unit._controller, weapon_profiles,
					"Choose fire mode:", Choice.Kind.GENERIC, {"actor": _unit})
		
		
		# --- targeting ------------------------------------------------------------
		var chosen_target = event.mover
		var targets : TargetSet = profile.target_set(_unit, chosen_target)
		
		
		# --- committing -----------------------------------------------------------
		expend_use()
		
		# --- ATTACK FLOW ----------------------------------------------------------
		
		# Step 1: roll dice for all targets.
		var unit_roll_events : Dictionary[Unit, AttackRollEvent]
		for target in targets.units:
			unit_roll_events[target] = AttackRollEvent.new(_unit, target)
			if profile.has_tag(WeaponProfile.WeaponTag.ACCURATE):
				unit_roll_events[target].accuracy += 1
			if profile.has_tag(WeaponProfile.WeaponTag.INACCURATE):
				unit_roll_events[target].difficulty += 1
			await BattleEngine.stage_event(unit_roll_events[target])
			await BattleEngine.resolve_event(unit_roll_events[target])
		
		# Step 2: check if anything will crit.
		var there_was_crit = false
		var unit_attacks : Dictionary[Unit, WeaponAttackEvent]
		
		for target in targets.units:
			
			# Gather what the rolls will be checking against
			var against = target.get_evasion()
			if profile.targets_e_defense():
				against = target.get_e_defense()
			
			# Gather the weapon hit rolls and only stage them
			unit_attacks[target] = WeaponAttackEvent.new(
				unit_roll_events[target],
				against,
				profile
			)
			await BattleEngine.stage_event(unit_attacks[target])
			
			# If any of them crit after staging, we remember it
			if unit_attacks[target].outcome() == WeaponAttackEvent.Outcome.CRIT:
				there_was_crit = true
		
		# Step 3: roll all damage, twice if crit.
		var damage_rolls
		if there_was_crit:
			damage_rolls = profile.roll_damage_crit()
		else:
			damage_rolls = profile.roll_damage()
		
		# Step 4: apply weapon hit to each.
		for target in targets.units:
			unit_attacks[target].damage_rolls = damage_rolls
			await BattleEngine.resolve_event(unit_attacks[target])
		
		weapon.consume_shot(profile)
		
	if event is RoundStartEvent:
		refresh_uses()
