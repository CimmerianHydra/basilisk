extends Node


var world : World
var _acting_controller : int = 0
var _controllers : Array[Controller] = []

func ask(controller : Controller, options: Array, prompt: String) -> Variant:
	var choice := Choice.new(options)
	choice._ctx["prompt"] = prompt
	await controller.decide(choice)
	return choice.get_answer()


func get_active_units(controlled_by : Controller) -> Array[Unit]:
	return world.get_units(func(u): return (u._controller == controlled_by and u._activations > 0))


func total_activations() -> int:
	var total = 0
	for u in world.get_units(): total += u._activations
	return total


func run_round():
	var total_acts = total_activations()
	print("New round. Activations: %s" % total_acts)
	while total_acts > 0:
		
		var controller = current_controller()
		
		var units = get_active_units(controller)
		if units.is_empty():
			go_next()
			continue
		
		print("%s's turn." % controller.display_name())
		
		var unit: Unit = await ask(controller,
			units,
			"Select unit to act:")
		
		# Notify all mods about the fact that the unit's turn is starting
		# Should be done using the BattleEvents system
		var turn_start_event = TurnStartEvent.new(unit)
		await stage_event(turn_start_event)
		await resolve_event(turn_start_event)
		
		var actions = unit.available_actions()
		
		while total_acts > 0:
			var action: BattleAction = await ask(controller,
				actions,
				"Select action for Unit %s:" % unit._name)
			
			await action.execute()
			
			# Special case: end turn
			if action is EndTurnAction:
				total_acts -= 1
				go_next()
				break
		
	print("The round ends.")

func go_next() -> void: _acting_controller = (_acting_controller + 1) % len(_controllers)
func current_controller(): return _controllers[_acting_controller]

## Emits some sort of event. Modifiers can edit the information on this event.
## Wondering if this should be the job of the World instead of the BattleEngine.
func stage_event(event : BattleEvent):
	var mods = world.get_modifiers()
	for mod in mods:
		await mod.on_event(event)

func resolve_event(event : BattleEvent):
	@warning_ignore("redundant_await")
	await event.resolve()
