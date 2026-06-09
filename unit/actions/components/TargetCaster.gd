extends ActionComponent
class_name TargetCaster

@export var replace_targets : bool = true

func validate(_ctx: Dictionary) -> bool:
	return true

# Override for the actual logic of the action. May use await internally for blocking components.
func execute(ctx: Dictionary) -> void:
	var caster = ctx[Action.CASTER_KEY]
	ctx[Action.TARGETS_KEY] = [caster]
