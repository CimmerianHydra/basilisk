extends Node

## Autoload. Drives the round loop and brokers Choices between rules and Controllers.
## Emits signals so an optional view layer can react; headless runs have no listeners.

signal event_staged(event: BattleEvent)
signal event_resolved(event: BattleEvent)

var world: World
var _acting_controller: int = 0
var _controllers: Array[Controller] = []


func ask(controller: Controller, options: Array, prompt: String,
		kind: Choice.Kind = Choice.Kind.GENERIC, ctx: Dictionary = {}) -> Variant:
	var choice := Choice.new(options, kind)
	choice._ctx = ctx.duplicate()
	choice._ctx["prompt"] = prompt
	await controller.decide(choice)
	return choice.get_answer()


func get_active_units(controlled_by: Controller) -> Array[Unit]:
	return world.get_units(func(u): return (u._controller == controlled_by and u._activations > 0))


func total_activations() -> int:
	var total := 0
	for u in world.get_units():
		total += u._activations
	return total


func run_round() -> void:
	var round_start_event := RoundStartEvent.new()
	await stage_event(round_start_event)
	await resolve_event(round_start_event)
	
	var total_acts := total_activations()
	print("New round. Activations: %s" % total_acts)
	while total_acts > 0:
		var controller := current_controller()
		
		var units := get_active_units(controller)
		if units.is_empty():
			go_next()
			continue
		
		print("%s's turn." % controller.display_name())
		
		var unit: Unit = await ask(controller, units,
				"Select unit to act:", Choice.Kind.PICK_UNIT)
		
		var turn_start_event := TurnStartEvent.new(unit)
		await stage_event(turn_start_event)
		await resolve_event(turn_start_event)
		
		var actions := unit.available_actions()
		
		while total_acts > 0:
			var action: BattleAction = await ask(controller, actions,
					"Select action for Unit %s:" % unit._name,
					Choice.Kind.PICK_ACTION, {"actor": unit})
			
			await action.execute()
			
			if action is EndTurnAction:
				total_acts -= 1
				go_next()
				break

	print("The round ends.")


func go_next() -> void:
	_acting_controller = (_acting_controller + 1) % len(_controllers)

func current_controller() -> Controller:
	return _controllers[_acting_controller]


## Lets modifiers edit the event's data before it plays out.
func stage_event(event: BattleEvent) -> void:
	event_staged.emit(event)
	
	# Phase 1: gather modifiers for the event
	var mods = world.get_modifiers()
	for mod in mods:
		await mod.on_event(event)
	
	# Phase 2: gather reactions for the event
	var reac = world.get_reactions()
	for rea in reac:
		await rea.on_event(event)


func resolve_event(event: BattleEvent) -> void:
	# Phase 1: check if event is still valid (TODO)
	
	# Phase 2: actually resolve the event if it's valid
	@warning_ignore("redundant_await")
	await event.resolve()
	event_resolved.emit(event)
