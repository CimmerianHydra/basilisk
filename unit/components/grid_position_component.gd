extends Node
class_name GridPositionComponent

signal moved(from_coord: Vector2i, to_coord: Vector2i)

@export var initial_coord: Vector2i = Vector2i.ZERO
@export var initial_height: int = 0

var coord: Vector2i
var height: int

var _grid: HexGrid3D = null
var _move_tween: Tween = null

# Defer the setup so that the scene has time to populate the map on _ready()
func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	_grid = get_tree().get_first_node_in_group(HexGrid.GROUP)
	if _grid == null:
		push_error("GridPositionComponent: no HexGrid found in scene.")
		return
	snap_to(initial_coord)

func _exit_tree() -> void:
	if _grid != null and is_instance_valid(_grid):
		var unit := get_parent() as Unit
		if unit != null:
			_grid.unregister_unit(unit)


## Instantly place the unit on the given tile.
func snap_to(new_coord: Vector2i) -> void:
	if _grid == null:
		return
	var unit := get_parent() as Unit
	if unit == null:
		push_error("GridPositionComponent: parent is not a Unit.")
		return
	if not _grid.has_tile(new_coord):
		push_warning("GridPositionComponent: tile %s does not exist on grid." % new_coord)
		return

	_grid.move_unit(unit, new_coord)
	coord = new_coord
	unit.position = _grid.coord_to_world(new_coord)


## Animate the unit to a single new tile. Updates grid occupancy at the start of
## the move. Use for teleports/pushes or as a flight straight-line move.
func move_to(new_coord: Vector2i, duration: float) -> void:
	if _grid == null:
		return
	var unit := get_parent() as Unit
	if unit == null:
		push_error("GridPositionComponent: parent is not a Unit.")
		return
	if not _grid.has_tile(new_coord):
		push_warning("GridPositionComponent: tile %s does not exist on grid." % new_coord)
		return

	var from_coord := coord
	_grid.move_unit(unit, new_coord)
	coord = new_coord

	var target_pos := _grid.coord_to_world(new_coord)

	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()

	if duration <= 0.0:
		unit.position = target_pos
		moved.emit(from_coord, new_coord)
		return

	_move_tween = create_tween()
	_move_tween.tween_property(unit, "position", target_pos, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _move_tween.finished
	moved.emit(from_coord, new_coord)


## Walk a path (ordered list of coords, excluding the start, ending on the
## destination) tile by tile, so ground units visibly round obstacles instead
## of cutting through them. A single-element path (flight) is one straight hop.
##
## Occupancy is updated to the FINAL tile up front — intermediate tiles are
## passed through visually but never reserved, which avoids occupancy flicker
## and keeps the destination claimed for the whole animation.
func move_along(path: Array, per_tile_duration: float) -> void:
	if _grid == null or path.is_empty():
		return
	var unit := get_parent() as Unit
	if unit == null:
		push_error("GridPositionComponent: parent is not a Unit.")
		return

	var final_coord: Vector2i = path[path.size() - 1]
	if not _grid.has_tile(final_coord):
		push_warning("GridPositionComponent: destination tile %s does not exist." % final_coord)
		return

	var from_coord := coord
	_grid.move_unit(unit, final_coord)
	coord = final_coord

	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()

	if per_tile_duration <= 0.0:
		unit.position = _grid.coord_to_world(final_coord)
		moved.emit(from_coord, final_coord)
		return

	_move_tween = create_tween()
	for step_coord in path:
		var step_pos := _grid.coord_to_world(step_coord)
		_move_tween.tween_property(unit, "position", step_pos, per_tile_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _move_tween.finished
	moved.emit(from_coord, final_coord)
