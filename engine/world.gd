extends RefCounted
class_name World

var _units : Array[Unit]
var _grid

var _rng : RandomNumberGenerator
var _mod : Array[Modifier]


func _init(rng_seed : int = 0) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = rng_seed

func d(sides : int) -> int:
	return _rng.randi_range(1, sides)

func get_units(filter : Callable = func(_x): return true): return _units.filter(filter)

func add_unit(unit : Unit):
	_units.append(unit)

func get_modifiers(filter : Callable = func(_x): return true):
	var to_return = []
	to_return.append_array(_mod)
	for u in get_units(): to_return.append_array(u.get_modifiers())
	return to_return.filter(filter)
