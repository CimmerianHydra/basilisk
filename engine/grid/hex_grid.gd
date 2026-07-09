class_name HexGrid
extends Resource

## The DATA MODEL for a 3D hex map. Pure data: tiles, topology, and the tactical
## queries (A* pathfinding, movement-range floodfill, line of sight). Holds no nodes and
## can run headless.
## A world object should be able to reconcile units occupying the grid.

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

@export var tiles: Dictionary = {} ## Vector2i(q, r) -> HexTile

# --- topology STATICS -------------------------------------------------------------

static func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for d: Vector2i in DIRECTIONS:
		result.append(coord + d)
	return result

static func get_neighbor(coord: Vector2i, dir: int) -> Vector2i:
	return coord + DIRECTIONS[dir]

static func opposite_direction(dir: int) -> int:
	return (dir + 3) % 6

## Axial (hex) distance between two coords, in tile steps.
static func distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	@warning_ignore("integer_division")
	return (absi(dq) + absi(dr) + absi(dq + dr)) / 2


# --- accessors ----------------------------------------------------------------------------

func has_tile(coord: Vector2i) -> bool:
	return tiles.has(coord)


func get_tile(coord: Vector2i) -> HexTile:
	return tiles.get(coord, null)


func set_tile(tile: HexTile) -> void:
	tiles[tile.coord] = tile


func get_height(coord: Vector2i) -> int:
	var t: HexTile = tiles.get(coord, null)
	return t.height if t != null else 0

# --- walls ----------------------------------------------------------------------------

## Top height (in integer levels) of whatever vertical obstruction sits on the shared
## edge between adjacent a and b. Walls are shared: it considers both tiles' facing
## faces, so an asymmetric wall set on only one side still blocks both ways.
func edge_obstruction_height(a: Vector2i, b: Vector2i) -> int:
	var dir := _direction_to(a, b)
	if dir == -1:
		return 0
	var result := 0
	var ta: HexTile = tiles.get(a, null)
	if ta != null:
		result = ta.effective_face_height(dir)
	var tb: HexTile = tiles.get(b, null)
	if tb != null:
		result = maxi(result, tb.effective_face_height(opposite_direction(dir)))
	return result


## True when a genuine WALL (a face rising above the taller of the two tiles) sits
## between adjacent a and b — i.e. it would stop a ground unit.
func is_wall_between(a: Vector2i, b: Vector2i) -> bool:
	return edge_obstruction_height(a, b) > maxi(get_height(a), get_height(b))


func _direction_to(a: Vector2i, b: Vector2i) -> int:
	var delta := b - a
	for d in DIRECTIONS.size():
		if DIRECTIONS[d] == delta:
			return d
	return -1


# --- traversal rule (single source of truth, the extension point) ---------------------

## Can a unit with `options` move directly from adjacent tile a to b?
## Today: blocked only by walls and impassable terrain. Height steps are gated by the
## profile's (currently permissive) max_step_* fields so cliffs are easy to enable later.
func can_traverse(a: Vector2i, b: Vector2i, options: MovementOptions) -> bool:
	if not has_tile(a) or not has_tile(b):
		return false
	if is_wall_between(a, b):
		return options.can_climb_walls # false for now -> walls block entirely
	var dh := get_height(b) - get_height(a)
	if dh > options.max_step_up:
		return false
	if -dh > options.max_step_down:
		return false
	#var tb: HexTile = tiles[b]
	#if tb.terrain != null and is_inf(tb.terrain.move_cost):
		#return false
	return true


## Cost to ENTER coord (driven by terrain WIP; falls back to the profile default).
func enter_cost(coord: Vector2i, options: MovementOptions) -> float:
	var _t: HexTile = tiles.get(coord, null)
	return options.default_move_cost


# --- floodfill: tiles within movement reach (Dijkstra) --------------------------------

## All tiles reachable from start for at most `budget` movement points.
## Returns { coord: accumulated_cost }, including start at cost 0.
func get_reachable(start: Vector2i, budget: float, options: MovementOptions,
		blocked: Dictionary = {}) -> Dictionary:
	return _dijkstra(start, budget, options, blocked)["costs"]


## Cheapest path to EVERY reachable tile in one sweep. Returns
## { coord: Array[Vector2i] }, each path excluding start and ending on coord
## (find_path's convention). start itself is not a key.
func get_reachable_paths(start: Vector2i, budget: float, options: MovementOptions,
		blocked: Dictionary = {}) -> Dictionary:
	var result := _dijkstra(start, budget, options, blocked)
	var came_from: Dictionary = result["came_from"]
	var paths := {}
	for coord: Vector2i in result["costs"]:
		if coord != start:
			paths[coord] = _reconstruct(came_from, coord)
	return paths


## Single-source Dijkstra; shared engine behind reachability and path harvesting.
## Returns { "costs": {coord: cost}, "came_from": {coord: coord} }.
func _dijkstra(start: Vector2i, budget: float, options: MovementOptions,
		blocked: Dictionary) -> Dictionary:
	var costs := {start: 0.0}
	var came_from := {}
	var visited := {}
	var pq := PriorityQueue.new()
	pq.push(start, 0.0)
	while not pq.is_empty():
		var current: Vector2i = pq.pop()
		if visited.has(current):
			continue
		visited[current] = true
		var current_cost: float = costs[current]
		for next in get_neighbors(current):
			if blocked.has(next) or not can_traverse(current, next, options):
				continue
			var new_cost: float = current_cost + enter_cost(next, options)
			if new_cost > budget:
				continue
			if not costs.has(next) or new_cost < costs[next]:
				costs[next] = new_cost
				came_from[next] = current
				pq.push(next, new_cost)
	return {"costs": costs, "came_from": came_from}


# --- A* pathfinding -------------------------------------------------------------------

## Shortest path from start to goal. Returns the route EXCLUDING start and ENDING on
## goal (matching GridPositionComponent.move_along), or [] if unreachable.
func find_path(start: Vector2i, goal: Vector2i, options: MovementOptions, blocked: Dictionary = {}) -> Array[Vector2i]:
	if start == goal or not has_tile(goal) or blocked.has(goal):
		return []
	var came_from := {}
	var g_score := {start: 0.0}
	var visited := {}
	var pq := PriorityQueue.new()
	pq.push(start, 0.0)
	while not pq.is_empty():
		var current: Vector2i = pq.pop()
		if visited.has(current):
			continue
		visited[current] = true
		if current == goal:
			return _reconstruct(came_from, current)
		var current_g: float = g_score[current]
		for next in get_neighbors(current):
			# The goal is allowed even if "blocked" so we can path adjacent to a target.
			if blocked.has(next) and next != goal:
				continue
			if not can_traverse(current, next, options):
				continue
			var tentative: float = current_g + enter_cost(next, options)
			if not g_score.has(next) or tentative < g_score[next]:
				g_score[next] = tentative
				came_from[next] = current
				pq.push(next, tentative + float(distance(next, goal)))
	return []


func _reconstruct(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	while came_from.has(current):
		current = came_from[current]
		path.insert(0, current)
	path.remove_at(0) # drop the start tile
	return path


# --- line of sight --------------------------------------------------------------------

### Can a viewer at the centre of `from` (eye at `from_level`, in height levels) see the
### centre of `to` (target at `to_level`)? Blocked by a wall or a taller tile body along
### the ray. Levels are floats so you can pass tile_height + an eye offset.
###
### NOTE: this samples the 3D segment at a fixed resolution — robust and tunable for
### tactical play, but an approximation. Swap in an exact hex supercover walk if you need
### pixel-perfect edge cases; the call sites won't change.
#func has_line_of_sight(from: Vector2i, to: Vector2i, from_level: float, to_level: float) -> bool:
	#if from == to:
		#return true
	#var p0 := layout.center_of(from)
	#p0.y = from_level * layout.height_step
	#var p1 := layout.center_of(to)
	#p1.y = to_level * layout.height_step
#
	#var horizontal := Vector2(p1.x - p0.x, p1.z - p0.z).length()
	#var steps := int(ceil(horizontal / (layout.size * 0.25))) + 1
	#var prev_coord := from
	#var prev_point := p0
	#for i in range(1, steps + 1):
		#var t := float(i) / float(steps)
		#var point := p0.lerp(p1, t)
		#var coord := layout.world_to_coord(point)
#
		## Crossing into a new hex: a wall (or tall tile side) on that edge can block.
		#if coord != prev_coord:
			#var wall_top := float(edge_obstruction_height(prev_coord, coord)) * layout.height_step
			#var cross_y := (prev_point.y + point.y) * 0.5
			#if wall_top > cross_y + 0.001:
				#return false
#
		## Tile body in the middle of the ray (endpoints never block themselves).
		#if coord != from and coord != to and has_tile(coord):
			#var tile := get_tile(coord)
			#var top := layout.top_y(tile.height)
			#if point.y < top - 0.001:
				#return false
			#if tile.terrain != null and tile.terrain.blocks_vision and point.y < top + layout.height_step:
				#return false
#
		#prev_coord = coord
		#prev_point = point
	#return true


# --- map generation -------------------------------------------------------------------

## Build a rectangular map (odd-r offset rows) with random tile heights in
## [0, max_tile_height]. Optionally sprinkle walls: each in-bounds edge has `wall_chance`
## of getting a wall rising 1..max_wall_height above the taller adjacent tile.
func generate_rectangular(width: int, rows: int, max_tile_height: int,
		wall_chance: float = 0.0, max_wall_height: int = 0, rng_seed: int = 0) -> HexGrid:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var coords: Array[Vector2i] = []
	for row in range(rows):
		for col in range(width):
			var q := col - ((row - (row & 1)) >> 1) # odd-r offset -> axial
			coords.append(Vector2i(q, row))

	return _build_from_coords(coords, max_tile_height, wall_chance, max_wall_height, rng)


## Build a hexagon-shaped ("circular") map: every tile within hex distance `radius` of the
## centre, i.e. the centre plus concentric rings 1..radius. Centred on axial (0, 0), so the
## map sits at the node origin. radius 0 = a single tile, radius N = 3N(N+1)+1 tiles.
## Heights, terrain and walls work exactly as in generate_rectangular.
func generate_circular(radius: int, max_tile_height: int,
		wall_chance: float = 0.0, max_wall_height: int = 0, rng_seed: int = 0) -> HexGrid:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var coords: Array[Vector2i] = []
	for q in range(-radius, radius + 1):
		var r_lo := maxi(-radius, -q - radius)
		var r_hi := mini(radius, -q + radius)
		for r in range(r_lo, r_hi + 1):
			coords.append(Vector2i(q, r))

	return _build_from_coords(coords, max_tile_height, wall_chance, max_wall_height, rng)


## Shared fill step for the generators: give each coord a random height and terrain, then
## optionally sprinkle walls. Keeping this separate means new map shapes only need to
## enumerate coordinates and hand them here.
func _build_from_coords(coords: Array[Vector2i], max_tile_height: int,
		wall_chance: float, max_wall_height: int, rng: RandomNumberGenerator) -> HexGrid:
	var grid := HexGrid.new()

	for coord: Vector2i in coords:
		var tile := HexTile.new()
		tile.coord = coord
		tile.height = rng.randi_range(0, max_tile_height)
		grid.set_tile(tile)

	if wall_chance > 0.0 and max_wall_height > 0:
		for coord: Vector2i in grid.tiles:
			var tile: HexTile = grid.tiles[coord]
			for d in DIRECTIONS.size():
				var neighbor := get_neighbor(coord, d)
				if not grid.has_tile(neighbor):
					continue
				if rng.randf() < wall_chance:
					# Set the wall on this tile's face only, so each edge gets a single
					# quad; is_wall_between stays symmetric via the max in edge logic.
					var base := maxi(tile.height, grid.get_height(neighbor))
					tile.set_wall(d, base + rng.randi_range(1, max_wall_height))
	return grid
