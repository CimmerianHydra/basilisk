extends Node
class_name HeatComponent

@export var health_component : HealthComponent
@export var max_heat : int = 10

var _current_heat : int = 0

func get_current_heat() -> int:
	return _current_heat

func take_heat(amount : int) -> void:
	_current_heat += amount
	if _current_heat >= max_heat:
		var damage : Dmg = Dmg.new()
		damage.amount = health_component.get_current_health()
		damage.type = Dmg.Type.ENERGY
		health_component.take_damage(damage)
