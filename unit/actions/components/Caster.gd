extends ActionComponent
class_name Caster

@export var caster: Unit

# Override for the actual logic of the action. May use await internally for blocking components.
func execute(ctx: Dictionary) -> void:
	ctx[Action.CASTER_KEY] = caster
