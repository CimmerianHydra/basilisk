extends BattleAction
class_name Skirmish

func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
	
	set_ctx("actor", _unit)
	set_ctx("action_cost", 1)
	await phase("quick_action")
	_unit._quick_actions -= get_ctx("action_cost")
	
	set_ctx("attacker", _unit)
	var weapon : WeaponDefinition = await BattleEngine.ask(_unit._controller, _unit._weapons, "Choose weapon for Skirmish:")
	set_ctx("weapon", weapon)
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	set_ctx("target", target)
	await phase("attack_roll")
	
	await phase("damage_roll")
	target.apply_damage(weapon.damage_die_sides, weapon.damage_type)

func display_name() -> String: return "Skirmish"
