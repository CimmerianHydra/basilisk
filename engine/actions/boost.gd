extends BattleAction
class_name Boost

## Base for any action that moves the unit across the grid (Standard Move, Boost,
## and later anything granting movement). Subclasses pay their costs, then call
## _perform_movement with a budget.

## Extra movement bought with a quick action: pay the cost, then move up to Speed.

func execute() -> void:
	print("Unit %s boosts!" % _unit.display_name())

	var payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(payment)
	await BattleEngine.resolve_event(payment)

	await _perform_movement(_unit.get_speed())

func display_name() -> String: return "Boost"

## Runs the full pick-and-move flow: reachable tiles minus invalid stands, a
## PICK_MOVE choice, then a staged UnitMoveEvent.
func _perform_movement(budget: int) -> void:
	var world := BattleEngine.world
	var grid: HexGrid = world._grid
	var start: Vector2i = _unit._position

	# You cannot path THROUGH hostile units (allies are fine to pass).
	var hostile_tiles := {}
	for other: Unit in world.get_units(func(u): return u._faction != _unit._faction):
		hostile_tiles[other._position] = true

	var paths := grid.get_reachable_paths(start, float(budget),
			_unit.get_movement_options(), hostile_tiles)

	# You cannot END on any occupied tile, friend or foe.
	var occupied := {}
	for other: Unit in world.get_units(func(u): return u != _unit):
		occupied[other._position] = true

	var destinations: Array = []
	for coord: Vector2i in paths:
		if not occupied.has(coord):
			destinations.append(coord)

	if destinations.is_empty():
		print("Unit %s has nowhere to move." % _unit.display_name())
		return

	var destination: Vector2i = await BattleEngine.ask(_unit._controller, destinations,
			"Select the destination:", Choice.Kind.PICK_MOVE,
			{"actor": _unit, "paths": paths})

	var route: Array[Vector2i] = []
	route.assign(paths[destination])
	var move := VoluntaryMoveEvent.new(_unit, route)
	await BattleEngine.stage_event(move)
	await BattleEngine.resolve_event(move)
