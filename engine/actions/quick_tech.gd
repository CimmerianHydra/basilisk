extends BattleAction
class_name QuickTech

func execute() -> void:
	print("Unit %s uses a Quick Tech!" % [_unit.display_name()])
	
	# Quick Action Cost Pay phase
	var quick_action_payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(quick_action_payment)
	await BattleEngine.resolve_event(quick_action_payment)
	
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	target.apply_damage(2, Damage.Type.HEAT)

func display_name() -> String: return "Quick Tech"
