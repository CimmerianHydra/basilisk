extends BattleAction
class_name Skirmish
## SKIRMISH: attack with a single, non-SUPERHEAVY weapon.
##
## The action is now a rules-blind script: offer only weapons
## that can actually fire, route the profile's TargetingQuery to the right
## picker, pay the cost, then resolve once per target in the resulting TargetSet.
##
## TODO: unify targeting mechanics and attack flow


func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
	
	# --- weapon: only what can legally fire right now is offered ------------
	var usable: Array[Weapon] = _unit._weapons.filter(
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
	var target_choice := profile.target_choice(_unit)
	if target_choice.get_options().is_empty():
		print("No valid targets, aborting action.")
		return
	var chosen_target = await BattleEngine.ask(_unit._controller, target_choice.get_options(),
				"Choose target:", target_choice._kind, {"actor": _unit})
	
	var targets : TargetSet = profile.target_set(_unit, chosen_target)
	
	
	# --- committing -----------------------------------------------------------
	var payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(payment)
	await BattleEngine.resolve_event(payment)
	
	
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
	# TODO(mounts): "you may also attack with a different AUXILIARY weapon on
	# the same mount" — a second, no-bonus-damage pass once mounts exist.
	# TODO(milestone 2): HEAT_SELF applies here, hit or miss.
 

func display_name() -> String: return "Skirmish"
