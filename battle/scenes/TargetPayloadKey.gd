extends ActionComponent
class_name TargetPayloadKey

@export var key : StringName = Action.TARGETS_KEY
@export var filter: UnitFilter

func execute(ctx: Dictionary) -> void:
	var payload = ctx[Action.PAYLOAD_KEY]
	var to_return : Array[Unit] = []
	for unit in payload[key]:
		to_return.append(unit)
	ctx[Action.TARGETS_KEY] = to_return
