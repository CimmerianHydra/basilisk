extends BattleAction
class_name QuickTech

func execute() -> void:
	print("Unit %s uses a Quick Tech!" % [_unit.display_name()])
	
	# Quick Action Cost Pay phase
	var quick_action_payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(quick_action_payment)
	await BattleEngine.resolve_event(quick_action_payment)
	
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(),
		"Choose target:", Choice.Kind.PICK_TARGET)
	
	var heat := HeatEvent.new(_unit, target, 2)
	await BattleEngine.stage_event(heat)
	await BattleEngine.resolve_event(heat)

func display_name() -> String: return "Quick Tech"
