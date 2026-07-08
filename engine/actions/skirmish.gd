extends BattleAction
class_name Skirmish

# NOTE: it seems like the structure of all these actions is always "write something in the context",
# then "await a phase", then "get something from the context".

# NOTE: it would be nice to create a standardized "phase" that modifiers can hook on to.
# This may eventually become the "BattleEvents" system, see comments below.

func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
	
	# Here if we were using the event system it would look like this
	var quick_action_payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(quick_action_payment)
	await BattleEngine.resolve_event(quick_action_payment)
	
	# Weapon and Target Selection phase
	var weapon : WeaponDefinition = await BattleEngine.ask(_unit._controller, _unit._weapons,
		"Choose weapon for Skirmish:", Choice.Kind.PICK_WEAPON)
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(),
		"Choose target:", Choice.Kind.PICK_TARGET)
	
	#set_ctx("attacker", _unit)
	#set_ctx("weapon", weapon)
	#set_ctx("target", target)
	
	# Slowly moving from the "phase" system to the "event" system.
	var atk_roll := AttackRollEvent.new(_unit, target)
	atk_roll.weapon = weapon
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
