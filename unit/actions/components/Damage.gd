extends ActionComponent
class_name Damage

@export var damage: Dmg

# Override for the actual logic of the action. May use await internally for blocking components.
func execute(ctx: Dictionary) -> void:
	for unit in ctx[Action.TARGETS_KEY]:
		await trigger("damage", ctx)
		unit.take_damage(damage)
		await get_tree().create_timer(1.0).timeout
