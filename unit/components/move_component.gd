extends Node
class_name MoveComponent

@export var move_budget : float = 0
@export var speed : float = 1.0
@export var profile : MovementProfile

var _current_budget : float

func _ready():
	replenish_budget()

func spend_budget(amount : float) -> void:
	_current_budget -= amount

func replenish_budget() -> void:
	_current_budget = move_budget

func get_remaining_budget() -> float:
	return _current_budget
