extends RefCounted
class_name BattleAction

var _unit : Unit

func _init(unit : Unit) -> void:
	_unit = unit

func execute() -> void: await ""
func display_name() -> String: return "..."
