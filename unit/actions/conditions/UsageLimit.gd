extends ActionCondition
class_name UsageLimit

@export var per_turn := 1

func check(_ctx : Dictionary) -> bool:
	return per_turn > 0
