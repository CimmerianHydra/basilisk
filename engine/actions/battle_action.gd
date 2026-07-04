extends RefCounted
class_name BattleAction

var _unit : Unit
var _ctx : Dictionary

func _init(unit : Unit) -> void:
	_unit = unit

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
