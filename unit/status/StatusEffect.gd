extends Node
class_name StatusEffect

@export var turn_duration := 1

var _turns_remaining := 0

func _ready():
	_turns_remaining = turn_duration

func decrement_turns_remaining(amount : int) -> void:
	_turns_remaining -= amount
	if _turns_remaining <= 0:
		queue_free()
