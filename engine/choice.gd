extends RefCounted
class_name Choice

var _options : Array = []
var _answer : Variant = null

var _ctx : Dictionary = {}

func _init(options : Array = []) -> void:
	_options = options

func get_answer() -> Variant:
	return _answer
