extends RefCounted
class_name Choice

enum Kind {
	GENERIC,
	CONFIRM,
	PICK_UNIT,
	PICK_ACTION,
	PICK_TARGET,
	PICK_WEAPON,
	PICK_SYSTEM,
	PICK_TECH,
	PICK_INVADE,
	PICK_MOVE,
	PICK_AOE_ANCHOR,
	PICK_TILE,
}

var _kind : Kind
var _options : Array
var _answer : Variant = null

var _ctx : Dictionary = {}

func _init(options : Array = [], kind : Kind = Kind.GENERIC) -> void:
	_options = options
	_kind = kind

func get_answer() -> Variant:
	return _answer

func get_options() -> Array:
	return _options

func prompt() -> String:
	return _ctx.get("prompt", "")
