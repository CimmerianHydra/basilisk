extends BattleAction
class_name Move

## Base for any action that moves the unit across the grid (Standard Move, Boost,
## and later anything granting movement). Subclasses pay their costs, then call
## _perform_movement with a budget.

## Extra movement bought with a quick action: pay the cost, then move up to Speed.

func execute() -> void:
	print("Unit %s moves!" % _unit.display_name())

	var route = await _pick_move(_unit._remaining_movement)
	var move := VoluntaryMoveEvent.new(_unit, route)
	await BattleEngine.stage_event(move)
	await BattleEngine.resolve_event(move)
	_unit._remaining_movement -= len(route)

func display_name() -> String: return "Move"
