class_name HexTile
extends Resource
## Per-tile data. Pure data — no visuals.
##
## height        : integer elevation level of the tile body (0 = ground plate).
## face_heights  : 6 entries, one per direction (see HexLayout.DIRECTIONS). A face is a
##                 "cover panel" on that edge. Its EFFECTIVE height is
##                 max(height, face_heights[dir]), so a face never sits below the tile,
##                 and a face left at its default simply inherits the tile height.
##                 A face is a WALL when face_heights[dir] > height (it rises above the
##                 tile body and renders as an upward double-sided quad).
## terrain       : shared TerrainType resource (movement cost, colour, vision, effects).

@export var coord: Vector2i = Vector2i.ZERO
@export var height: int = 0
@export var face_heights: PackedInt32Array = PackedInt32Array([0, 0, 0, 0, 0, 0])
@export var terrain: TerrainType

## Live occupant, set at runtime by HexGrid3D. Not meaningful to serialise.
var occupant: Node = null


## Effective height of a face: never below the tile itself.
func effective_face_height(dir: int) -> int:
	return maxi(height, face_heights[dir])


## True when this face rises above the tile body, i.e. it is a wall.
func is_wall(dir: int) -> bool:
	return face_heights[dir] > height


func set_wall(dir: int, wall_height: int) -> void:
	face_heights[dir] = wall_height
