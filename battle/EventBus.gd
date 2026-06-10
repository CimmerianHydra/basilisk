extends Node
class_name EventBus

const GROUP := "event_bus"
var _registry : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(GROUP)

## Registers the action onto the global event bus. When trigger() is called,
## the bus calls each action registered here and waits for the completed signal.
func register(action: Action, channel: String) -> void:
	if _registry.has(channel):
		_registry[channel].append(action)
	else:
		_registry[channel] = [action]

## Deregisters the action from the event bus registry.
func deregister(action: Action, channel: String) -> void:
	if _registry.has(channel):
		_registry[channel].erase(action)
	else:
		push_error("EventBus triggered an event on channel '%s', but it doesn't exist on the registry." % channel)

## Triggers a message containing the payload onto the specified channel. Every
## registered action listens to it, so it's up to them to filter out which ones
## a unit can actually act upon and if they are going to trigger other things.
func trigger(channel: String, payload: Dictionary):
	if channel == "button":
		push_error("Attempted to trigger EventBus on the 'button' channel, which is forbidden.")
		return
	if not _registry.has(channel):
		push_warning("EventBus triggered an event on channel '%s', but it doesn't exist on the registry." % channel)
		return
	for action in _registry[channel]:
		await action.run(payload.duplicate(true))
	return
