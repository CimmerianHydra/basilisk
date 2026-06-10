extends ActionCondition
class_name AnyUnit

@export var unit_filter: UnitFilter = UnitFilter.new()

func check(_ctx : Dictionary) -> bool:
	var roster := get_tree().get_first_node_in_group(UnitRoster.GROUP) as UnitRoster
	var units := roster.get_units()
	return unit_filter.filter_array(units).size() > 0
