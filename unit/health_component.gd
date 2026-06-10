extends Node
class_name HealthComponent

signal destroyed

@export var structure : int = 1
@export var max_health : int = 10

var _current_health : int = 10

func _ready() -> void:
	_current_health = max_health

func get_current_health() -> int:
	return _current_health

func get_current_structure() -> int:
	return structure

func take_damage(damage : Dmg) -> void:
	_current_health -= damage.amount
	
	if _current_health <= 0:
		structure -= 1
		_current_health += max_health
		
	if structure <= 0:
		destroyed.emit()
