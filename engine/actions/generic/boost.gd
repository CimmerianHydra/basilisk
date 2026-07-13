extends BattleAction
class_name Boost

## Base for any action that moves the unit across the grid (Standard Move, Boost,
## and later anything granting movement). Subclasses pay their costs, then call
## _perform_movement with a budget.

## Extra movement bought with a quick action: pay the cost, then move up to Speed.

func execute() -> void:
	print("Unit %s boosts!" % _unit.display_name())

	var payment := QuickActionCastEvent.new(_unit)
	await BattleEngine.stage_event(payment)
	await BattleEngine.resolve_event(payment)

	var route = await _pick_move(_unit.get_speed())
	var move := VoluntaryMoveEvent.new(_unit, route)
	await BattleEngine.stage_event(move)
	await BattleEngine.resolve_event(move)

func display_name() -> String: return "Boost"
