class_name TerrainType
extends Resource
## Data + behaviour scaffolding for a kind of terrain (soil, snow, sand, bushes...).
## Pure data.
##
## The *_actions() hooks are the scaffolding for terrain affecting units: they return
## the game's Action objects to apply when a unit enters / exits / passes through a tile
## of this terrain. They return [] by default — subclass TerrainType (or attach a script)
## per terrain and override these to inject real Actions later, without touching the grid.

@export var id: StringName = &"soil"
@export var display_name: String = "Soil"
@export var color: Color = Color(0.45, 0.36, 0.27)
## Cost to ENTER a tile of this terrain during movement. >1 = slow, INF = impassable.
## Keep at >= 1.0 for A* optimality (the heuristic assumes a minimum step cost of 1).
@export var move_cost: float = 1.0
## If true, the terrain body itself blocks line of sight (e.g. dense foliage).
@export var blocks_vision: bool = false


## Actions applied when a unit ENTERS a tile of this terrain. Override to populate.
func get_enter_actions(_unit: Node) -> Array:
	return []


## Actions applied when a unit LEAVES a tile of this terrain.
func get_exit_actions(_unit: Node) -> Array:
	return []


## Actions applied when a unit PASSES THROUGH (steps over) this tile mid-path.
func get_pass_actions(_unit: Node) -> Array:
	return []
