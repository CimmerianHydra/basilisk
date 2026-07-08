extends BattleEvent
class_name VoluntaryMoveEvent

## A unit relocating along a path.

## INITIAL DATA
var _mover: Unit
var _path: Array[Vector2i]

## FINAL DATA
var mover: Unit
var path: Array[Vector2i] ## Excludes the start tile; ends on the destination.


func _init(p_mover: Unit, p_path: Array[Vector2i]) -> void:
	setup(p_mover, p_path)


func setup(p_mover: Unit, p_path: Array[Vector2i]) -> void:
	_mover = p_mover
	_path = p_path
	mover = p_mover
	path = p_path.duplicate()


func destination() -> Vector2i:
	return path.back() if not path.is_empty() else mover._position


func resolve() -> void:
	mover._position = destination()
