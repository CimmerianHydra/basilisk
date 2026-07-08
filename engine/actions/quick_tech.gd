extends BattleAction
class_name QuickTech

func execute() -> void:
	print("Unit %s uses a Quick Tech!" % [_unit.display_name()])
	
	# Quick Action Cost Pay phase
	set_ctx("actor", _unit)
	set_ctx("action_cost", 1)
	await phase("quick_action")
	_unit._quick_actions -= get_ctx("action_cost")
	
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	target.apply_damage(2, Damage.Type.HEAT)

func display_name() -> String: return "Quick Tech"
