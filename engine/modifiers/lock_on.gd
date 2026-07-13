extends Modifier
class_name LockOn

var _target : Unit

func _init(target : Unit) -> void:
	_target = target
	_ticks = 1

func _on_event(event : BattleEvent) -> void:
	if event is AttackRollEvent:
		if not event.defender == _target: return
		var consumed = await BattleEngine.ask(event.attacker._controller, [true, false], "Consume Lock On?")
		if consumed:
			event.accuracy += 1
			event.lock_on_consumed = true # TODO: this could be an event too?
			tick_zero()
