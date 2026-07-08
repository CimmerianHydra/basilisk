extends BattleAction
class_name EndTurnAction

func execute() -> void:
	print("Unit %s's turn ends." % [_unit.display_name()])
	var turn_end_event := TurnEndEvent.new(_unit)
	await BattleEngine.stage_event(turn_end_event)
	await BattleEngine.resolve_event(turn_end_event)

func display_name() -> String: return "End Turn"
