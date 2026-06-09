@tool
extends EasyStateMachine
class_name TurnState

const GROUP := "turn_state"

func _ready():
	super()
	add_to_group(GROUP)
