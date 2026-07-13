extends BattleAction
class_name Overcharge

func execute() -> void:
	var oc := Overcharged.new(_unit)
	var oc_event := GiveConditionEvent.new(_unit, oc)
	oc_event.source = _unit
	_unit._oc_counter += 1
	await BattleEngine.stage_event(oc_event)
	await BattleEngine.resolve_event(oc_event)

func display_name() -> String: return "Overcharge"
