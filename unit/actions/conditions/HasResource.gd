extends ActionCondition
class_name HasResource

@export var unit : Unit
@export var amount : int = 1

@onready var action_point := self.get_child(0)

func check(_ctx: Dictionary) -> bool:
	var resource_library : BattleResourceLibrary = unit.resource_library
	var count = 0
	for res in resource_library.get_children():
		if res.get_script() == action_point.get_script():
			count += 1
	return count >= amount
