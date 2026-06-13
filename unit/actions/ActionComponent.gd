extends Node
class_name ActionComponent

# Override for setup-time checks. Return false to skip this component.
func validate(_action_context: Dictionary) -> bool:
	return true

# Override for the actual logic of the action. May use await internally for blocking components.
func execute(_action_context: Dictionary) -> void:
	return

# Don't override.
func trigger(channel: String, payload: Dictionary) -> void:
	var event_bus = get_tree().get_first_node_in_group(EventBus.GROUP)
	if event_bus == null:
		push_error("ActionComponent '%s' couldn't find the EventBus." % self.name)
		return
	await event_bus.trigger(channel, payload)

# Don't override.
func execute_children(ctx: Dictionary) -> void:
	for child in self.get_children():
		if child is ActionComponent:
			if child.validate(ctx):
				await child.execute(ctx)
			else:
				push_warning("ActionComponent '%s' failed validation; skipping." % child.name)
