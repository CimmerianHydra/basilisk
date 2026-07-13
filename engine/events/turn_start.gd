extends BattleEvent
class_name TurnStartEvent

## INITIAL DATA
var _actor : Unit

## FINAL DATA
var actor : Unit = _actor

func _init(p_actor : Unit) -> void:
	setup(p_actor)

func setup(p_actor : Unit) -> void:
	_actor = p_actor
	actor = p_actor

func resolve() -> void:
	actor.turn_start()
