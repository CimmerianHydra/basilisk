extends BattleEvent
class_name QuickActionCastEvent

## INITIAL DATA
var _actor : Unit
var _cost : int = 1

## FINAL DATA
var actor : Unit = _actor
var cost : int = _cost

func _init(p_actor : Unit) -> void:
	setup(p_actor)

func setup(p_actor : Unit) -> void:
	_actor = p_actor
	actor = p_actor

func resolve() -> void:
	actor._quick_actions -= cost
