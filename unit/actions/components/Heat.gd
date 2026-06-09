extends ActionComponent
class_name Heat

@export var amount: int = 0

func execute(ctx: Dictionary) -> void:
	var caster = ctx[Action.CASTER_KEY]
	for unit in ctx[Action.TARGETS_KEY]:
		await trigger("heat", ctx)
		print("Unit '{0}' takes {1} points of heat from Unit '{2}'.".format([unit.name, amount, caster.name]))
