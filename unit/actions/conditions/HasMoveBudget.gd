extends ActionCondition
class_name HasMoveBudget

@export var unit : Unit

func check(_ctx: Dictionary) -> bool:
	var remaining_budget = unit.move_component.get_remaining_budget()
	return remaining_budget > 0
