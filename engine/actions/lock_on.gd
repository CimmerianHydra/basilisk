extends BattleAction
class_name LockOn

func execute() -> void:
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	print("Unit %s Locks On to Unit %s!" % [_unit.display_name(), target.display_name()])

func display_name() -> String: return "Lock On"
