extends UnitFilter
class_name FilterByCheck

@export var context_key : StringName = Action.D20_ROLL_KEY
@export var action : Action

var _ctx : Dictionary

func filter_array(units : Array[Unit]) -> Array[Unit]:
	var to_return : Array[Unit] = []
	for unit in units:
		if filter(unit):
			to_return.append(unit)
	return to_return

func filter(unit : Unit) -> bool:
	var evasion = unit.find_child("EvasionComponent").evasion
	_ctx = action._action_context
	return evasion < _ctx[context_key]
