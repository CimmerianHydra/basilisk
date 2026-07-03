extends BattleAction
class_name Skirmish

func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
	var weapon : WeaponDefinition = await BattleEngine.ask(_unit._controller, _unit._weapons, "Choose weapon for Skirmish:")
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	target.apply_damage(weapon.damage_die_sides, weapon.damage_type)

func display_name() -> String: return "Skirmish"
