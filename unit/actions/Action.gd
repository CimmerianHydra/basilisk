extends Node
class_name Action

@export_category("Trigger")
@export var trigger_channel : String = "button"

@export_category("Button")
@export var has_button : bool
@export var button_definition : ButtonDefinition

signal completed
signal checked

var _action_context: Dictionary = {}
var _bus: EventBus

func _ready() -> void:
	_bus = get_tree().get_first_node_in_group(EventBus.GROUP)
	register_to_bus()

func register_to_bus() -> void:
	if _bus == null:
		push_error("Action '%s' couldn't find the EventBus." % self.name)
		return
	_bus.register(self, trigger_channel)
	return

func run(payload: Dictionary = {}) -> void:
	_action_context = {}
	_action_context[PAYLOAD_KEY] = payload

	for child in get_children():
		if child is not ActionComponent:
			continue
		if not child.validate(_action_context):
			push_warning("Action '%s': component '%s' failed validation; interrupting." % [name, child.name])
			break
		await child.execute(_action_context)
	
	await GlobalSignals.emit_signal("action_completed", self)
	completed.emit()
	return

func check(payload: Dictionary = {}) -> bool:

	for child in get_children():
		if child is not ActionCondition:
			continue
		if not child.validate(payload):
			push_warning("Action '%s': condition '%s' failed validation; interrupting." % [name, child.name])
			break
		if not child.check(payload):
			return false
		
	checked.emit()
	return true

# ---------- OFTEN USED CONTEXT KEYS ---------- #

const CASTER_KEY = &"caster"
const TARGETS_KEY = &"targets"
const TILES_KEY = &"tiles"
const PAYLOAD_KEY = &"payload"
const D20_ROLL_KEY = &"d20_roll"
