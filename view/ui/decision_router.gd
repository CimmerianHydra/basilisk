class_name DecisionRouter
extends ChoicePresenter

## Dispatches each Choice to the interaction mode fitting its kind, and points the
## camera at whatever the player is being asked about. Unit picks happen in 3D,
## action/weapon picks get the radial menu, everything else falls back to the list.

var _units: UnitLayer
var _camera: RTSCamera
var _fallback: ChoicePresenter
var _radial: ChoicePresenter
var _tiles: MoveHighlightLayer


func _init(units: UnitLayer, tiles: MoveHighlightLayer, camera: RTSCamera,
		fallback: ChoicePresenter, radial: ChoicePresenter) -> void:
	_units = units
	_tiles = tiles
	_camera = camera
	_fallback = fallback
	_radial = radial


func present(choice: Choice) -> Variant:
	match choice._kind:
		Choice.Kind.PICK_UNIT, Choice.Kind.PICK_TARGET:
			_frame_units(choice.get_options())
			return await _units.pick_unit(choice.get_options())
		Choice.Kind.PICK_ACTION, Choice.Kind.PICK_WEAPON, Choice.Kind.GENERIC:
			var actor: Unit = choice._ctx.get("actor")
			if actor != null:
				_frame_units([actor])
			return await _radial.present(choice)
		Choice.Kind.PICK_MOVE:
			if _camera != null:
				_camera.frame_positions(_tiles.positions_of(choice.get_options()))
			return await _tiles.pick_tile(choice.get_options(), _preview_paths(choice))
		_:
			return await _fallback.present(choice)

func _frame_units(units: Array) -> void:
	if _camera == null:
		return
	var positions := _units.positions_of(units)
	if not positions.is_empty():
		_camera.frame_positions(positions)

## Engine paths exclude the start tile; for drawing, prepend the actor's position
## so the line visibly begins at the unit's feet.
func _preview_paths(choice: Choice) -> Dictionary:
	var actor: Unit = choice._ctx.get("actor")
	var paths: Dictionary = choice._ctx.get("paths", {})
	if actor == null or paths.is_empty():
		return {}
	var full := {}
	for coord: Vector2i in paths:
		var route: Array = [actor._position]
		route.append_array(paths[coord])
		full[coord] = route
	return full
