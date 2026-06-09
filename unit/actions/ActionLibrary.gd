extends Node
class_name ActionLibrary

func get_button_definitions_and_actions() -> Array:
	var to_return = []
	for action in get_available_actions():
		if action.has_button:
			to_return.append([action.button_definition, action])
	return to_return

func get_available_actions() -> Array:
	var to_return = []
	for child in get_children():
		if (child is Action) and (child.check()):
			to_return.append(child)
	return to_return
