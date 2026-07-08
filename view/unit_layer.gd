class_name UnitLayer
extends Node3D

## Spawns and tracks one UnitView per model Unit, keeps them placed on the grid,
## and runs the 3D unit-picking interaction used by the DecisionRouter.

signal _unit_picked(unit: Unit)

const UNIT_VIEW_SCENE: PackedScene = preload("res://view/unit/unit_view.tscn")

@export var seconds_per_tile: float = 0.18

var _layout: HexLayout
var _grid: HexGrid
var _views: Dictionary = {} ## Unit -> UnitView

func _ready() -> void:
	BattleEngine.event_resolved.connect(_on_event_resolved)

func _on_event_resolved(event: BattleEvent) -> void:
	if event is VoluntaryMoveEvent:
		_animate_move(event.mover, event.path)

## Runs the view tile-by-tile along the (already resolved) route.
func _animate_move(unit: Unit, path: Array[Vector2i]) -> void:
	var view := view_of(unit)
	if view == null or path.is_empty():
		refresh_positions()
		return
	var tween := create_tween()
	for coord: Vector2i in path:
		var pos := _layout.center_of(coord)
		pos.y = _layout.top_y(_grid.get_height(coord))
		tween.tween_property(view, "position", pos, seconds_per_tile)
	# Ease only the last hop, so the run is steady and the stop is soft.
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func build(world: World, grid: HexGrid, layout: HexLayout) -> void:
	clear()
	_grid = grid
	_layout = layout
	for unit: Unit in world.get_units():
		var view: UnitView = UNIT_VIEW_SCENE.instantiate()
		view.setup(unit)
		view.clicked.connect(_on_view_clicked)
		add_child(view)
		_views[unit] = view
	refresh_positions()


func clear() -> void:
	for child in get_children():
		child.queue_free()
	_views.clear()


func view_of(unit: Unit) -> UnitView:
	return _views.get(unit, null)


## Re-derives every view's world position from its unit's grid coordinate.
## Call after any event that moves units (there are none yet).
func refresh_positions() -> void:
	for unit: Unit in _views:
		var view: UnitView = _views[unit]
		var pos := _layout.center_of(unit._position)
		pos.y = _layout.top_y(_grid.get_height(unit._position))
		view.position = pos

## World positions of the given units' views (at roughly chest height), for camera
## framing or any other spatial query.
func positions_of(units: Array) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for unit: Unit in units:
		var view := view_of(unit)
		if view != null:
			result.append(view.position + Vector3.UP * 0.6)
	return result

## Highlights the given units, waits for the player to click one, returns it.
func pick_unit(options: Array) -> Unit:
	for unit: Unit in options:
		var view := view_of(unit)
		if view != null:
			view.set_selectable(true)

	var chosen: Unit = await _unit_picked

	for unit: Unit in options:
		var view := view_of(unit)
		if view != null:
			view.set_selectable(false)

	return chosen


func _on_view_clicked(unit: Unit) -> void:
	_unit_picked.emit(unit)
