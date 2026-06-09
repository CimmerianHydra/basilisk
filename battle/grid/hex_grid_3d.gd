extends Node3D
class_name HexGrid3D
## Runtime VISUAL + INTERACTION layer over a HexGrid data model.
## Builds a prism (+ wall quads) view per tile, routes mouse hover/click into signals,
## and tracks live unit occupancy. All map *truth* lives in `grid`; this node only renders
## it and reports input. Units locate this node via the HexGrid.HEX_GRID_GROUP group.
##
## coord_to_world() returns positions in THIS node's local space. Keep HexGrid3D at the
## world origin, or parent your units under it, so unit.position lands correctly.

signal tile_clicked(coord: Vector2i, button: int)
signal tile_hovered(coord: Vector2i)
signal tile_unhovered(coord: Vector2i)

@export var grid: HexGrid: set = set_grid
@export var build_on_ready: bool = true
@export var tile_material: StandardMaterial3D ## Optional template; albedo is overridden per terrain.
@export var wall_material: StandardMaterial3D  ## Optional template for cover walls.

var _tile_views: Dictionary = {} # Vector2i -> Node3D
var _occupants: Dictionary = {}  # Vector2i -> Node (unit)
var _hovered: Vector2i = Vector2i.ZERO
var _has_hover: bool = false


func _ready() -> void:
	add_to_group(HexGrid.GROUP)
	get_viewport().physics_object_picking = true
	if build_on_ready and grid != null:
		rebuild()


func set_grid(value: HexGrid) -> void:
	grid = value
	if is_inside_tree() and build_on_ready:
		rebuild()


# --- build ----------------------------------------------------------------------------

func rebuild() -> void:
	for child in get_children():
		child.queue_free()
	_tile_views.clear()
	if grid == null:
		return
	for coord: Vector2i in grid.tiles:
		_build_tile_view(grid.tiles[coord])


func get_tile_view(coord: Vector2i) -> Node3D:
	return _tile_views.get(coord, null)


func _build_tile_view(tile: HexTile) -> void:
	var layout := grid.layout
	var root := Node3D.new()
	root.name = "Tile_%d_%d" % [tile.coord.x, tile.coord.y]
	root.position = layout.center_of(tile.coord)
	root.set_meta("coord", tile.coord)

	# Body prism.
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = HexMeshBuilder.build_prism(layout, tile.height)
	body.material_override = _make_tile_material(tile)
	root.add_child(body)

	# Walls: one quad per face that rises above the tile.
	var base_y := layout.top_y(tile.height)
	for d in HexLayout.DIRECTIONS.size():
		if not tile.is_wall(d):
			continue
		var wall := MeshInstance3D.new()
		wall.name = "Wall_%d" % d
		var wall_top := float(tile.effective_face_height(d)) * layout.height_step
		wall.mesh = HexMeshBuilder.build_wall(layout, d, base_y, wall_top)
		wall.material_override = _make_wall_material()
		root.add_child(wall)

	# Picking: a convex hex-prism collider per tile.
	var area := Area3D.new()
	area.name = "Picker"
	area.input_ray_pickable = true
	var shape := CollisionShape3D.new()
	shape.shape = _make_pick_shape(layout, tile)
	area.add_child(shape)
	area.mouse_entered.connect(_on_tile_mouse_entered.bind(tile.coord))
	area.mouse_exited.connect(_on_tile_mouse_exited.bind(tile.coord))
	area.input_event.connect(_on_tile_input_event.bind(tile.coord))
	root.add_child(area)

	add_child(root)
	_tile_views[tile.coord] = root


func _make_tile_material(tile: HexTile) -> StandardMaterial3D:
	var mat: StandardMaterial3D = tile_material.duplicate() if tile_material != null else StandardMaterial3D.new()
	if tile.terrain != null:
		mat.albedo_color = tile.terrain.color
	return mat


func _make_wall_material() -> StandardMaterial3D:
	if wall_material != null:
		return wall_material
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.5, 0.55)
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


func _make_pick_shape(layout: HexLayout, tile: HexTile) -> ConvexPolygonShape3D:
	var top := layout.top_y(tile.height)
	var pts := PackedVector3Array()
	for i in 6:
		var c := layout.corner_offset(i)
		pts.append(Vector3(c.x, 0.0, c.z))
		pts.append(Vector3(c.x, top, c.z))
	var shape := ConvexPolygonShape3D.new()
	shape.points = pts
	return shape


# --- picking -> centralised signals ---------------------------------------------------

func _on_tile_mouse_entered(coord: Vector2i) -> void:
	if _has_hover and _hovered == coord:
		return
	if _has_hover:
		tile_unhovered.emit(_hovered)
	_hovered = coord
	_has_hover = true
	tile_hovered.emit(coord)


func _on_tile_mouse_exited(coord: Vector2i) -> void:
	if _has_hover and _hovered == coord:
		_has_hover = false
		tile_unhovered.emit(coord)


func _on_tile_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int, coord: Vector2i) -> void:
	if event is InputEventMouseButton and event.pressed:
		tile_clicked.emit(coord, event.button_index)
	elif event is InputEventScreenTouch and event.pressed:
		tile_clicked.emit(coord, MOUSE_BUTTON_LEFT)


# --- API used by GridPositionComponent ------------------------------------------------

func has_tile(coord: Vector2i) -> bool:
	return grid != null and grid.has_tile(coord)


## Walking-surface position for a tile, in this node's local space.
func coord_to_world(coord: Vector2i) -> Vector3:
	return grid.surface_position(coord) if grid != null else Vector3.ZERO


func move_unit(unit: Node, to_coord: Vector2i) -> void:
	_clear_unit(unit)
	_occupants[to_coord] = unit
	var tile := grid.get_tile(to_coord) if grid != null else null
	if tile != null:
		tile.occupant = unit


func unregister_unit(unit: Node) -> void:
	_clear_unit(unit)


func _clear_unit(unit: Node) -> void:
	for c: Vector2i in _occupants.keys():
		if _occupants[c] == unit:
			_occupants.erase(c)
			var t := grid.get_tile(c) if grid != null else null
			if t != null and t.occupant == unit:
				t.occupant = null


func get_occupant(coord: Vector2i) -> Node:
	return _occupants.get(coord, null)


## Occupied tiles as a { coord: true } set, for passing into pathfinding as `blocked`.
func occupied_coords() -> Dictionary:
	var blocked := {}
	for c: Vector2i in _occupants:
		blocked[c] = true
	return blocked


# --- convenience wrappers (occupancy-aware) -------------------------------------------

func find_path(start: Vector2i, goal: Vector2i, profile: MovementProfile, avoid_occupied: bool = true) -> Array[Vector2i]:
	if grid == null:
		return []
	return grid.find_path(start, goal, profile, occupied_coords() if avoid_occupied else {})


func get_reachable(start: Vector2i, budget: float, profile: MovementProfile, avoid_occupied: bool = true) -> Dictionary:
	if grid == null:
		return {}
	return grid.get_reachable(start, budget, profile, occupied_coords() if avoid_occupied else {})


## Line of sight between two tiles, with eye/target heights given as world-space offsets
## above each tile's surface (e.g. ~1.6 m eye height).
func has_line_of_sight(from: Vector2i, to: Vector2i, eye_offset: float = 1.0, target_offset: float = 1.0) -> bool:
	if grid == null:
		return false
	var step := grid.layout.height_step
	var from_level := float(grid.get_height(from)) + eye_offset / step
	var to_level := float(grid.get_height(to)) + target_offset / step
	return grid.has_line_of_sight(from, to, from_level, to_level)

func get_units_within_range(from: Vector2i, radius: int) -> Array[Unit]:
	var to_return: Array[Unit] = []
	for occupied_tile in _occupants.keys():
		var occupant = _occupants[occupied_tile]
		if occupant is Unit:
			if grid.layout.distance(from, occupied_tile) <= radius:
				to_return.append(occupant)
	return to_return

func highlight_tiles(coords : Array[Vector2i]) -> void:
	for coord in coords:
		var view = get_tile_view(coord)
		var body = view.get_child(0)
		body.material_override.albedo_color = Color.AQUA * (1 - 0.2 * randf())

func higlight_off() -> void:
	rebuild()
