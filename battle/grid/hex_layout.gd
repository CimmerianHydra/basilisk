class_name HexLayout
extends Resource
## Pure geometry + coordinate math for a pointy-top hex grid. No nodes, no visuals.
## Coordinates are axial Vector2i(q, r). The grid lies on the XZ plane; Y is up (height).
##
## This is "data" in the data/visual split: HexGrid uses it for topology and LOS,
## HexGrid3D uses the same instance to place meshes, so model and view never disagree.

const SQRT3 := 1.7320508075688772

## Axial neighbour offsets, indexed by direction 0..5.
const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

## For each direction, the two corner indices (0..5) bounding the shared edge.
## Corner i sits at angle (60*i - 30) degrees; this table aligns each wall quad with
## the edge that faces the neighbour in that direction.
const DIRECTION_EDGE_CORNERS: Array = [
	[0, 1], [5, 0], [4, 5], [3, 4], [2, 3], [1, 2],
]

@export var size: float = 1.0             ## Centre → corner radius, in world units.
@export var height_step: float = 0.5      ## World units per integer height level.
@export var plate_thickness: float = 0.12 ## Thickness of a height-0 tile plate.


func get_neighbor(coord: Vector2i, dir: int) -> Vector2i:
	return coord + DIRECTIONS[dir]


func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for d: Vector2i in DIRECTIONS:
		result.append(coord + d)
	return result


func opposite_direction(dir: int) -> int:
	return (dir + 3) % 6


## Axial (hex) distance between two coords, in tile steps.
func distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	@warning_ignore("integer_division")
	return (absi(dq) + absi(dr) + absi(dq + dr)) / 2


## Centre of a tile on the ground plane (y = 0).
func center_of(coord: Vector2i) -> Vector3:
	var x := size * (SQRT3 * coord.x + SQRT3 * 0.5 * coord.y)
	var z := size * (1.5 * coord.y)
	return Vector3(x, 0.0, z)


## World XZ → nearest axial coord (ignores y).
func world_to_coord(world: Vector3) -> Vector2i:
	var q := (SQRT3 / 3.0 * world.x - 1.0 / 3.0 * world.z) / size
	var r := (2.0 / 3.0 * world.z) / size
	return _axial_round(q, r)


## Corner offset i (0..5) relative to tile centre, on the ground plane (y = 0).
func corner_offset(i: int) -> Vector3:
	var angle := deg_to_rad(60.0 * i - 30.0)
	return Vector3(size * cos(angle), 0.0, size * sin(angle))


## World Y of the top (walking surface) of a tile at the given integer height level.
func top_y(height_level: int) -> float:
	if height_level <= 0:
		return plate_thickness
	return float(height_level) * height_step

func _axial_round(q: float, r: float) -> Vector2i:
	var x := q
	var z := r
	var y := -x - z
	var rx := roundf(x)
	var ry := roundf(y)
	var rz := roundf(z)
	var dx := absf(rx - x)
	var dy := absf(ry - y)
	var dz := absf(rz - z)
	if dx > dy and dx > dz:
		rx = -ry - rz
	elif dy > dz:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector2i(int(rx), int(rz))
