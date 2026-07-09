extends BattleAction
class_name Skirmish

# NOTE: it seems like the structure of all these actions is always "write something in the context",
# then "await an event", then "get something from the context".

func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
	
	# Here if we were using the event system it would look like this
	var quick_action_payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(quick_action_payment)
	await BattleEngine.resolve_event(quick_action_payment)
	
	# Weapon and Target Selection phase
	var weapon : WeaponDefinition = await BattleEngine.ask(_unit._controller, _unit._weapons,
		"Choose weapon for Skirmish:", Choice.Kind.PICK_WEAPON)
	
	# temporary until we figure out AoE and tile selection
	var target : Unit
	
	# The targets depend on the chosen weapon.
	# Some weapons target tiles, some target units.
	var attack_kind = weapon.attack_kind
	var radius : int = mini(weapon.max_range, _unit._frame.sensors)
	
	var target_kind = weapon.target_kind
	if target_kind == WeaponDefinition.TargetKind.UNIT:
		target = await BattleEngine.ask(
			_unit._controller,
			BattleEngine.world.get_enemy_units_in_range(_unit, radius),
			"Choose target:",
			Choice.Kind.PICK_TARGET
			)
	# TODO: tile selection for AoE and such
	
	var atk_roll := AttackRollEvent.new(_unit, target)
	atk_roll.weapon = weapon
	if attack_kind == WeaponDefinition.AttackKind.MELEE:
		atk_roll._ignores_cover = true
	await BattleEngine.stage_event(atk_roll)
	await BattleEngine.resolve_event(atk_roll)
	
	# TODO: need to make this into something else so we can apply evasion or
	# e-defense as needed
	# Could be rolled into the attack roll?
	if atk_roll.total >= target.get_evasion():
		await phase("attack_hit")
		
		if atk_roll.total >= 20:
			await phase("attack_crit")
		
		await phase("damage_roll_prep")
		await phase("damage_roll_eval")
		
		target.apply_damage(weapon.damage_die_sides, weapon.damage_type)
	else:
		await phase("attack_miss")

func display_name() -> String: return "Skirmish"
