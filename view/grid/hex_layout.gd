class_name HexLayout
extends Resource

## Maps axial hex coordinates to 3D world space and back. Pointy-top hexes on the
## XZ plane, +Y up. Corner i sits at angle (60*i - 30) degrees, matching
## HexGrid.DIRECTION_EDGE_CORNERS. Shared by all views; holds no nodes.

const SQRT3 := 1.7320508075688772

@export var size: float = 1.0        ## Distance from hex centre to a corner.
@export var height_step: float = 0.5 ## World-space height of one elevation level.


## World-space centre of a tile, at elevation 0.
func center_of(coord: Vector2i) -> Vector3:
	var x := size * (SQRT3 * coord.x + SQRT3 * 0.5 * coord.y)
	var z := size * (1.5 * coord.y)
	return Vector3(x, 0.0, z)


## Y of the top surface of a tile with the given integer height.
func top_y(height: int) -> float:
	return height * height_step


## World position of corner 0..5 of a hex, at elevation 0.
func corner_of(coord: Vector2i, corner: int) -> Vector3:
	var angle := deg_to_rad(60.0 * corner - 30.0)
	return center_of(coord) + Vector3(size * cos(angle), 0.0, size * sin(angle))


## Inverse mapping: world position -> nearest axial coordinate.
func world_to_coord(point: Vector3) -> Vector2i:
	var q := (SQRT3 / 3.0 * point.x - 1.0 / 3.0 * point.z) / size
	var r := (2.0 / 3.0 * point.z) / size
	return _axial_round(q, r)


func _axial_round(q: float, r: float) -> Vector2i:
	var s := -q - r
	var rq := roundf(q)
	var rr := roundf(r)
	var rs := roundf(s)
	var dq := absf(rq - q)
	var dr := absf(rr - r)
	var ds := absf(rs - s)
	if dq > dr and dq > ds:
		rq = -rr - rs
	elif dr > ds:
		rr = -rq - rs
	return Vector2i(int(rq), int(rr))
