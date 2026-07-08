class_name MovementOptions
extends Resource
## Rules a unit uses to traverse the grid. Pure data. Passed into HexGrid pathfinding
## and reachability so different unit types can move differently.
##
## CURRENT RULES (per spec): a wall on the shared edge blocks movement entirely, and
## tile-to-tile height differences do NOT block (units walk over elevation freely).
## The fields below are the extension hooks the spec asked for:
##   - flip `can_climb_walls` once "climb over walls / reach new heights" movement exists;
##   - lower `max_step_up` / `max_step_down` to forbid stepping up/down cliffs.
## They default to permissive so only walls block today.

@export var can_climb_walls: bool = false
## Max height a unit may step UP between adjacent tiles. Large default = no cliff limit.
@export var max_step_up: int = 1
## Max height a unit may step DOWN between adjacent tiles.
@export var max_step_down: int = 99
## Fallback per-tile enter cost when a tile has no TerrainType assigned.
@export var default_move_cost: float = 1.0
