extends ActionComponent
class_name TargetPayloadKey

## Allows the extraction of a specific key from the passed-in payload
## (for example, from a reaction trigger) and selecting all units in that key as
## targets.
## For example, the default configuration of this component extracts the "caster"
## key from the payload and sets it as target for the action.

@export var key : StringName = Action.TARGETS_KEY

func execute(ctx: Dictionary) -> void:
	var payload = ctx[Action.PAYLOAD_KEY]
	var array : Array[Unit] = []
	for unit in payload[key]:
		array.append(unit)
	ctx[Action.TARGETS_KEY] = array
