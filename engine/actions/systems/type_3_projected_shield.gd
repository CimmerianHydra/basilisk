extends BattleAction
class_name Type3ProjectedShieldAction

## "Nominate a character within line of sight: all
## ranged or melee attacks that they make against
## you or that you make against them gain +2 DIFF
## until the start of your next turn"

func execute() -> void:
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(),
		"Choose target:", Choice.Kind.PICK_TARGET)
	
	var protocol_event := ProtocolCastEvent.new(_unit)
	await BattleEngine.stage_event(protocol_event)
	await BattleEngine.resolve_event(protocol_event)
	
	var heat_event := HeatEvent.new(_unit, _unit, 1)
	await BattleEngine.stage_event(heat_event)
	await BattleEngine.resolve_event(heat_event)
	
	var condition := Type3ProjectedShieldMod.new(_unit, target)
	var condition_event := GiveConditionEvent.new(_unit, condition)
	condition_event.source = _unit
	await BattleEngine.stage_event(condition_event)
	await BattleEngine.resolve_event(condition_event)

func display_name() -> String: return "Activate Type-3 Projected Shield"
