extends ActionCondition
class_name HasStatusEffect

@export var unit : Unit

@onready var status := self.get_child(0)

func check(_ctx: Dictionary) -> bool:
	var status_effect_container : Node = unit.status_effect_container
	for effect in status_effect_container.get_children():
		if effect.get_script() == status.get_script():
			return true
	return false
