class_name MoveHighlightLayer
extends Node3D

## Presents "pick a tile" interactions: spawns a thin translucent platform over
## each candidate tile, flashes the hovered one white, and reports the click.
## Mesh, collision shape, and materials are built once and shared by all platforms.

signal _tile_picked(coord: Vector2i)

const BASE_COLOR := Color(1.0, 0.85, 0.2, 0.45)
const HOVER_COLOR := Color(1.0, 1.0, 1.0, 0.7)
const PATH_COLOR := Color(1.0, 1.0, 1.0, 0.9)

## Lift of the preview line above tile surfaces, clearing the platforms.
@export var path_height: float = 0.2

var _platform_root: Node3D
var _preview_paths: Dictionary = {} ## Vector2i -> full route incl. start
var _path_mesh: ImmediateMesh

@export var thickness: float = 0.05
## Lift above the tile surface, to dodge z-fighting with the tile top.
@export var surface_offset: float = 0.02

var _grid: HexGrid
var _layout: HexLayout
var _platform_mesh: ArrayMesh
var _pick_shape: ConvexPolygonShape3D
var _base_material: StandardMaterial3D
var _hover_material: StandardMaterial3D
var _meshes_by_coord: Dictionary = {} ## Vector2i -> MeshInstance3D


func build(grid: HexGrid, layout: HexLayout) -> void:
	_grid = grid
	_layout = layout
	_base_material = _make_material(BASE_COLOR)
	_hover_material = _make_material(HOVER_COLOR)
	_platform_root = Node3D.new()
	add_child(_platform_root)

	_path_mesh = ImmediateMesh.new()
	var path_line := MeshInstance3D.new()
	path_line.mesh = _path_mesh
	path_line.material_override = _make_material(PATH_COLOR)
	add_child(path_line)
	
	_build_platform_mesh()
	_build_pick_shape()


## Highlights the given tiles, waits for a click, returns the chosen coord.
## preview_paths (optional): coord -> full route INCLUDING the start tile; when a
## platform is hovered, its route is drawn as a line over the terrain.
func pick_tile(coords: Array, preview_paths: Dictionary = {}) -> Vector2i:
	_preview_paths = preview_paths
	for coord: Vector2i in coords:
		_spawn_platform(coord)

	var chosen: Vector2i = await _tile_picked
	clear()
	return chosen


func clear() -> void:
	for child in _platform_root.get_children():
		child.queue_free()
	_meshes_by_coord.clear()
	_preview_paths = {}
	_clear_path()


## World positions of the given tiles' surfaces, for camera framing.
func positions_of(coords: Array) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for coord: Vector2i in coords:
		var pos := _layout.center_of(coord)
		pos.y = _layout.top_y(_grid.get_height(coord))
		result.append(pos)
	return result


func _spawn_platform(coord: Vector2i) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = _platform_mesh
	mesh_instance.material_override = _base_material

	var shape := CollisionShape3D.new()
	shape.shape = _pick_shape

	var area := Area3D.new()
	area.add_child(mesh_instance)
	area.add_child(shape)
	area.position = _layout.center_of(coord) \
			+ Vector3.UP * (_layout.top_y(_grid.get_height(coord)) + surface_offset)
	area.input_event.connect(_on_input_event.bind(coord))
	area.mouse_entered.connect(_set_hover.bind(coord, true))
	area.mouse_exited.connect(_set_hover.bind(coord, false))
	_platform_root.add_child(area)

	_meshes_by_coord[coord] = mesh_instance


func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3,
		_normal: Vector3, _shape_idx: int, coord: Vector2i) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_tile_picked.emit(coord)


func _set_hover(coord: Vector2i, hovered: bool) -> void:
	var mesh_instance: MeshInstance3D = _meshes_by_coord.get(coord, null)
	if mesh_instance != null:
		mesh_instance.material_override = _hover_material if hovered else _base_material
	if hovered:
		_draw_path(coord)
	else:
		_clear_path()


func _draw_path(coord: Vector2i) -> void:
	_path_mesh.clear_surfaces()
	var route: Array = _preview_paths.get(coord, [])
	if route.size() < 2:
		return
	_path_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for c: Vector2i in route:
		var point := _layout.center_of(c)
		point.y = _layout.top_y(_grid.get_height(c)) + path_height
		_path_mesh.surface_add_vertex(point)
	_path_mesh.surface_end()


func _clear_path() -> void:
	_path_mesh.clear_surfaces()

## Thin hex prism in local space: a top cap at `thickness` plus a side skirt.
## No bottom face — it always sits flush on a tile, so nobody ever sees it.
func _build_platform_mesh() -> void:
	var corners: Array[Vector3] = []
	for i in 6:
		corners.append(_layout.corner_of(Vector2i.ZERO, i))

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in 6:
		var j := (i + 1) % 6
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(0.0, thickness, 0.0))
		st.add_vertex(corners[i] + Vector3.UP * thickness)
		st.add_vertex(corners[j] + Vector3.UP * thickness)

	for i in 6:
		var j := (i + 1) % 6
		var normal := (corners[i] + corners[j]).normalized()
		var a := corners[i] + Vector3.UP * thickness
		var b := corners[j] + Vector3.UP * thickness
		st.set_normal(normal)
		st.add_vertex(a); st.add_vertex(corners[i]); st.add_vertex(corners[j])
		st.set_normal(normal)
		st.add_vertex(a); st.add_vertex(corners[j]); st.add_vertex(b)

	_platform_mesh = st.commit()


func _build_pick_shape() -> void:
	var points := PackedVector3Array()
	for i in 6:
		var corner := _layout.corner_of(Vector2i.ZERO, i)
		points.append(corner)
		points.append(corner + Vector3.UP * thickness)
	_pick_shape = ConvexPolygonShape3D.new()
	_pick_shape.points = points


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	return material
