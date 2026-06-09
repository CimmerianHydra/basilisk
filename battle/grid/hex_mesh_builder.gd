class_name HexMeshBuilder
extends RefCounted
## Static mesh construction for hex tiles and walls. Builds geometry only; callers assign
## materials. Uses the same HexLayout math as the data model, so visuals line up exactly.

## A hexagonal prism from y = 0 up to the tile's top surface. A height-0 tile becomes a
## thin plate (layout.plate_thickness); height > 0 becomes a prism of height*height_step.
static func build_prism(layout: HexLayout, height_level: int) -> ArrayMesh:
	var top := layout.top_y(height_level)
	var corners: Array[Vector3] = []
	for i in 6:
		corners.append(layout.corner_offset(i))

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Top face (fan around centre), facing up.
	st.set_normal(Vector3.UP)
	for i in 6:
		var a := Vector3(corners[i].x, top, corners[i].z)
		var b := Vector3(corners[(i + 1) % 6].x, top, corners[(i + 1) % 6].z)
		st.add_vertex(Vector3(0, top, 0)); st.add_vertex(a); st.add_vertex(b)

	# Bottom face (fan), facing down — reversed winding.
	st.set_normal(Vector3.DOWN)
	for i in 6:
		var a := Vector3(corners[i].x, 0.0, corners[i].z)
		var b := Vector3(corners[(i + 1) % 6].x, 0.0, corners[(i + 1) % 6].z)
		st.add_vertex(Vector3.ZERO); st.add_vertex(b); st.add_vertex(a)

	# Six side quads, each with an outward horizontal normal.
	for i in 6:
		var c0 := corners[i]
		var c1 := corners[(i + 1) % 6]
		var mid := (c0 + c1) * 0.5
		var nrm := Vector3(mid.x, 0.0, mid.z).normalized()
		st.set_normal(nrm)
		var bl := Vector3(c0.x, 0.0, c0.z)
		var br := Vector3(c1.x, 0.0, c1.z)
		var tl := Vector3(c0.x, top, c0.z)
		@warning_ignore("shadowed_variable_base_class")
		var tr := Vector3(c1.x, top, c1.z)
		st.add_vertex(bl); st.add_vertex(br); st.add_vertex(tr)
		st.add_vertex(bl); st.add_vertex(tr); st.add_vertex(tl)

	return st.commit()


## A double-sided wall quad on edge `dir`, from base_y up to top_y, sitting at the tile
## edge. Front and back faces are built explicitly so lighting is correct from both sides.
static func build_wall(layout: HexLayout, dir: int, base_y: float, top_y: float) -> ArrayMesh:
	var pair: Array = HexLayout.DIRECTION_EDGE_CORNERS[dir]
	var c0 := layout.corner_offset(pair[0])
	var c1 := layout.corner_offset(pair[1])
	var bl := Vector3(c0.x, base_y, c0.z)
	var br := Vector3(c1.x, base_y, c1.z)
	var tl := Vector3(c0.x, top_y, c0.z)
	@warning_ignore("shadowed_variable_base_class")
	var tr := Vector3(c1.x, top_y, c1.z)
	var mid := (c0 + c1) * 0.5
	var nrm := Vector3(mid.x, 0.0, mid.z).normalized()

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Front.
	st.set_normal(nrm)
	st.add_vertex(bl); st.add_vertex(br); st.add_vertex(tr)
	st.add_vertex(bl); st.add_vertex(tr); st.add_vertex(tl)
	# Back (flipped winding + normal).
	st.set_normal(-nrm)
	st.add_vertex(bl); st.add_vertex(tr); st.add_vertex(br)
	st.add_vertex(bl); st.add_vertex(tl); st.add_vertex(tr)
	return st.commit()
