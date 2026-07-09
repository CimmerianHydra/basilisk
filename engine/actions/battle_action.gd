extends RefCounted
class_name BattleAction

var _unit : Unit
var _ctx : Dictionary

func _init(unit : Unit) -> void:
	_unit = unit


@warning_ignore("redundant_await")
func execute() -> void: await ""
func is_available() -> bool: return true

func set_ctx(key, value) -> void: _ctx[key] = value
func get_ctx(key, default = null) -> Variant:
	if not _ctx.has(key):
		push_warning("Context of BattleAction %s does not have a %s key." % [display_name(), key] )
		return default
	else: return _ctx[key]

func set_window(name : String): set_ctx("window", name)

func apply_modifiers(filter : Callable = func(_x): return true):
	var mods = BattleEngine.world.get_modifiers(filter)
	for mod in mods:
		await mod.apply(_ctx)

func phase(name : String, mod_filter : Callable = func(_x): return true):
	set_window(name)
	await apply_modifiers(mod_filter)

func display_name() -> String: return "..."


# -------- HELPERS ---------

## Runs the full pick-and-move flow: reachable tiles minus invalid stands, a
## PICK_MOVE choice, then a staged UnitMoveEvent.
func _pick_move(budget: int) -> Array[Vector2i]:
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
		return []

	var destination: Vector2i = await BattleEngine.ask(_unit._controller, destinations,
			"Select the destination:", Choice.Kind.PICK_MOVE,
			{"actor": _unit, "paths": paths})

	var route: Array[Vector2i] = []
	route.assign(paths[destination])
	return route
