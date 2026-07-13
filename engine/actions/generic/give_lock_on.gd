extends BattleAction
class_name GiveLockOn

func execute() -> void:
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(),
		"Choose target:", Choice.Kind.PICK_TARGET)
	var lock_on := LockOn.new(target)
	var lock_on_event := GiveConditionEvent.new(target, lock_on)
	lock_on_event.source = _unit
	await BattleEngine.stage_event(lock_on_event)
	await BattleEngine.resolve_event(lock_on_event)

func display_name() -> String: return "Lock On"
