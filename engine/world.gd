extends RefCounted
class_name World

var _units : Array[Unit]
var _grid

var _rng : RandomNumberGenerator



func _init(rng_seed : int = 0) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = rng_seed

func d(sides : int) -> int:
	return _rng.randi_range(1, sides)

func get_units(filter : Callable = func(_x): return true): return _units.filter(filter)

func add_unit(unit : Unit):
	_units.append(unit)
