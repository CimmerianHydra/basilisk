extends ActionComponent
class_name ClearStatusEffectAll

@export var status_effect_container : Node
@export var amount := 1

func execute(_ctx: Dictionary) -> void:
	for child in status_effect_container.get_children():
		if (child is StatusEffect):
			child.decrement_turns_remaining(amount)
