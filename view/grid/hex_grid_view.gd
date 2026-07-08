class_name HexGridView
extends Node3D

## Builds meshes visualising a HexGrid (pure data). One MeshInstance3D per tile:
## a hex prism for the tile body plus double-sided quads for its walls.

@export var tile_material: StandardMaterial3D
@export var wall_material: StandardMaterial3D

var _layout: HexLayout
var _tile_views: Dictionary = {} ## Vector2i -> MeshInstance3D


func build(grid: HexGrid, layout: HexLayout) -> void:
	clear()
	_layout = layout
	if tile_material == null:
		tile_material = _default_material(Color(0.45, 0.55, 0.4))
	if wall_material == null:
		wall_material = _default_material(Color(0.35, 0.32, 0.3), true)

	for coord: Vector2i in grid.tiles:
		var tile: HexTile = grid.tiles[coord]
		var view := MeshInstance3D.new()
		view.mesh = _tile_mesh(tile)
		view.position = layout.center_of(coord)
		add_child(view)
		_tile_views[coord] = view


func clear() -> void:
	for child in get_children():
		child.queue_free()
	_tile_views.clear()


func _tile_mesh(tile: HexTile) -> ArrayMesh:
	# Local-space corners (the MeshInstance3D itself sits at the tile centre).
	var corners: Array[Vector3] = []
	for i in 6:
		corners.append(_layout.corner_of(Vector2i.ZERO, i))

	var top := _layout.top_y(tile.height)
	var mesh := _body_surface(corners, top)
	_append_wall_surface(mesh, tile, corners, top)
	return mesh


func _body_surface(corners: Array[Vector3], top: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(tile_material)

	# Top cap: fan around the centre. Corner order is clockwise seen from above,
	# which is Godot's front-face winding.
	for i in 6:
		var j := (i + 1) % 6
		st.set_normal(Vector3.UP)
		st.add_vertex(Vector3(0.0, top, 0.0))
		st.add_vertex(corners[i] + Vector3.UP * top)
		st.add_vertex(corners[j] + Vector3.UP * top)

	# Side skirt down to ground level, one outward-facing quad per edge.
	if top > 0.0:
		for i in 6:
			var j := (i + 1) % 6
			var normal := (corners[i] + corners[j]).normalized()
			var a := corners[i] + Vector3.UP * top
			var b := corners[j] + Vector3.UP * top
			var c := corners[j]
			var d := corners[i]
			st.set_normal(normal)
			st.add_vertex(a); st.add_vertex(d); st.add_vertex(c)
			st.set_normal(normal)
			st.add_vertex(a); st.add_vertex(c); st.add_vertex(b)

	return st.commit()


func _append_wall_surface(mesh: ArrayMesh, tile: HexTile,
		corners: Array[Vector3], top: float) -> void:
	var has_walls := false
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(wall_material)

	for dir in 6:
		if not tile.is_wall(dir):
			continue
		has_walls = true
		var wall_top := tile.face_heights[dir] * _layout.height_step
		var edge: Array = HexGrid.DIRECTION_EDGE_CORNERS[dir]
		var a: Vector3 = corners[edge[0]] + Vector3.UP * top
		var b: Vector3 = corners[edge[1]] + Vector3.UP * top
		var c: Vector3 = corners[edge[1]] + Vector3.UP * wall_top
		var d: Vector3 = corners[edge[0]] + Vector3.UP * wall_top
		var normal := (a + b).normalized()
		st.set_normal(normal)
		st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
		st.set_normal(normal)
		st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)

	if has_walls:
		st.commit(mesh) # Appends as a second surface with the wall material.


func _default_material(color: Color, double_sided := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color * randf_range(0.9, 1.0)
	if double_sided:
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material
