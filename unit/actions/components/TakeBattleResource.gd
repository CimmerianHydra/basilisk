extends ActionComponent
class_name TakeBattleResource

@onready var action_point := self.get_child(0)

func execute(ctx: Dictionary) -> void:
	for unit in ctx[Action.TARGETS_KEY]:
		var resource_library : BattleResourceLibrary = unit.resource_library
		var resources_of_unit = resource_library.get_children()
		var found_resources = []
		for res in resources_of_unit:
			if res.get_script() == action_point.get_script():
				found_resources.append(res)
		if found_resources.size() == 0:
			push_error("Action component '%s' could not find resources of same type as '%s'." % [self.name, action_point.name])
			return
		var to_remove = found_resources[0]
		resource_library.remove_child(to_remove)
		to_remove.queue_free()
