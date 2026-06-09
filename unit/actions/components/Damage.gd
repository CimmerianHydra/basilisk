extends ActionComponent
class_name Damage

@export var damage: Dmg

# Override for the actual logic of the action. May use await internally for blocking components.
func execute(ctx: Dictionary) -> void:
	var caster = ctx[Action.CASTER_KEY]
	for unit in ctx[Action.TARGETS_KEY]:
		await trigger("damage", ctx)
		print("Unit '{0}' takes {1} points of damage from Unit '{2}'.".format([unit.name, damage.amount, caster.name]))
