extends ActionComponent
class_name FilterUnitArray

@export var context_key: StringName = Action.TARGETS_KEY
@export var unit_filter: UnitFilter = UnitFilter.new()

# Override for the actual logic of the action. May use await internally for blocking components.
func execute(ctx: Dictionary) -> void:
	if not ctx.has(context_key):
		push_error("Action component '%s' cannot find key '%s' in context." % self.name, context_key)
		return
	if not (ctx[context_key] is Array[Unit]):
		push_error("Context key '%s' is not an array of unit." % context_key)
		return

	ctx[context_key] = unit_filter.filter_array(ctx[context_key])
