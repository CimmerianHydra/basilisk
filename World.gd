extends Node
class_name World

var events : Array[Event] = []
var board

func add_modifier(mod : Modifier) -> void:
	add_child(mod)
