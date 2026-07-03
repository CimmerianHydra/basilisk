extends BattleAction
class_name EndTurnAction

func execute() -> void:
	print("Unit %s's turn ends." % [_unit.display_name()])
	_unit._activations -= 1

func display_name() -> String: return "End Turn"
