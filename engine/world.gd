extends RefCounted
class_name World

var _units : Array[Unit]
var _grid : HexGrid

var _rng : RandomNumberGenerator
var _global_mods : Array[Modifier]


func _init(rng_seed : int = 0) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = rng_seed

func d(sides : int) -> int:
	return _rng.randi_range(1, sides)

func get_units(filter : Callable = func(_x): return true): return _units.filter(filter)

## Prepackaged helper for a specific kind of filter that is very common
func get_enemy_units_in_range(enemies_of : Unit, in_range : int):
	var filter = func(u : Unit):
		var is_enemy = u._faction != enemies_of._faction
		var is_in_range = HexGrid.distance(u._position, enemies_of._position) <= in_range
		return is_enemy and is_in_range
	return get_units(filter)

func add_unit(unit : Unit):
	_units.append(unit)

func get_modifiers(filter : Callable = func(_x): return true):
	var to_return = []
	to_return.append_array(_global_mods)
	for u in get_units(): to_return.append_array(u.get_modifiers())
	return to_return.filter(filter)
