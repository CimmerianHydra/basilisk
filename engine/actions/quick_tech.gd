extends BattleAction
class_name QuickTech

func execute() -> void:
	print("Unit %s uses a Quick Tech!" % [_unit.display_name()])
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	target.apply_damage(2, Damage.Type.HEAT)

func display_name() -> String: return "Quick Tech"
