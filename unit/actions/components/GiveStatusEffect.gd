extends ActionComponent
class_name GiveStatusEffect

@onready var effect_to_give := self.get_child(0)

func execute(ctx: Dictionary) -> void:
	for unit in ctx[Action.TARGETS_KEY]:
		var template_effect = effect_to_give.duplicate()
		unit.status_effect_container.add_child(template_effect)
