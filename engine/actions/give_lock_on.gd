extends BattleAction
class_name GiveLockOn

func execute() -> void:
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	var lock_on := LockOn.new(target)
	target.add_modifier(lock_on)

func display_name() -> String: return "Lock On"
