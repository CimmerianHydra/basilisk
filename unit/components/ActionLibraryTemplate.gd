extends Node
class_name ActionLibraryTemplate

@export var action_library : ActionLibrary

func replenish_actions() -> void:
	for child in get_children():
		var new_child = child.duplicate()
		action_library.add_child(new_child)
