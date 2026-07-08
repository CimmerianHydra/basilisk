extends BattleEvent
class_name GiveConditionEvent

## INITIAL DATA
var _source : Unit
var _target : Unit
var _condition : Modifier

## FINAL DATA
var source : Unit
var target : Unit
var condition : Modifier

func _init(p_target : Unit, p_condition : Modifier) -> void:
	setup(p_target, p_condition)

func setup(p_target : Unit, p_condition : Modifier) -> void:
	_target = p_target
	_condition = p_condition
	target = p_target
	condition = p_condition

func resolve() -> void:
	target.add_modifier(condition)
