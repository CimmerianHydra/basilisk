extends Modifier
class_name Overcharged

var _target : Unit

func _init(target : Unit) -> void:
	_target = target
	_ticks = 1

func _on_event(event : BattleEvent) -> void:
	if event is QuickActionCastEvent:
		if not event.actor == _target: return
		var use = await BattleEngine.ask(event.actor._controller, [true, false], "Make Quick Action free?")
		if use:
			event.cost = 0
			tick_zero()
	if event is TurnEndEvent:
		if not event.actor == _target: return
		tick_down()
