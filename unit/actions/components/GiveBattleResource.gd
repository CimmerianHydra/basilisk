extends ActionComponent
class_name GiveBattleResource

@onready var resource_to_give := self.get_child(0)

func execute(ctx: Dictionary) -> void:
	for unit in ctx[Action.TARGETS_KEY]:
		var template_resource = resource_to_give.duplicate()
		unit.resource_library.add_child(template_resource)
