extends RefCounted
class_name Unit

enum Faction { PLAYER, ENEMY }

@export var _name : String
@export var _frame : FrameDefinition

## BATTLE STATE
var _health : int = 0 # Health Points
var _heat : int = 0 # Heat Points
var _structure : int = 0 # Structure Points
var _stress : int = 0 # Stress Points
var _weapons : Array[Weapon] = []
var _position : Vector2i = Vector2i.ZERO
var _oc_counter : int = 0

## MOVEMENT
var _remaining_movement : int = 0
var _movement_options : MovementOptions = MovementOptions.new()

## CONTROLLER
var _controller : Controller
var _faction := Faction.PLAYER

## ACTION ECONOMY
var _activations : int = 1
var _quick_actions : int = 2
var _usable_reactions : int = 1
var _can_use_protocol : bool = true
var _actions_from_systems : Array[BattleAction] = []

## EVENT RESPONDERS
var _modifiers : Array[Modifier]
var _reactions : Array[Reaction] = [Overwatch.new(self)]
var _reactions_from_systems : Array[Reaction] = []

## SYSTEMS
var _systems : Array[System]

func _init(name, frame : FrameDefinition = FrameDefinition.new()) -> void:
	_name = name
	_frame = frame
	_health = frame.max_hp

func turn_start() -> void:
	_remaining_movement = get_speed()
	_quick_actions = 2
	_usable_reactions = 1
	_can_use_protocol = true



# ----- BATTLE ENGINE SETTERS AND GETTERS -----

func set_controller(controller : Controller) -> void:
	_controller = controller

func add_weapon(definition : WeaponDefinition) -> void:
	var w = Weapon.new(definition)
	_weapons.append(w)

func add_system(definition : SystemDefinition) -> void:
	var s = System.new(definition)
	_systems.append(s)
	for a_script in s.definition.action_grants:
		add_action(a_script.new(self))

func add_action(action : BattleAction) -> void:
	_actions_from_systems.append(action)

func add_modifier(mod : Modifier) -> void:
	_modifiers.append(mod)

func get_modifiers() -> Array[Modifier]:
	# Clean up first so we never hand over expired mods
	for mod in _modifiers.duplicate():
		if mod._ticks == 0: _modifiers.erase(mod)
	return _modifiers

func get_reactions() -> Array[Reaction]:
	var to_return : Array[Reaction] = []
	for r in _reactions:
		if r._uses > 0: to_return.append(r)
	for r in _reactions_from_systems:
		if r._uses > 0: to_return.append(r)
	return to_return

func available_actions() -> Array[BattleAction]:
	var general_actions : Array[BattleAction] = []
	general_actions.append(Skirmish.new(self))
	general_actions.append(QuickTech.new(self))
	general_actions.append(Move.new(self))
	general_actions.append(Boost.new(self))
	if _controller is HumanController:
		general_actions.append(Overcharge.new(self))
	general_actions.append(GiveLockOn.new(self))
	general_actions.append_array(_actions_from_systems)
	general_actions.append(EndTurnAction.new(self))
	return general_actions

# ----- BATTLE STAT GETTERS -----

func get_evasion() -> int:
	return _frame.evasion

func get_e_defense() -> int:
	return _frame.e_defense

func get_armor() -> int:
	return _frame.armor

func get_speed() -> int:
	return _frame.speed

func get_movement_options() -> MovementOptions:
	return _movement_options

# ----- HP -----

func get_hp() -> int:
	return _health

func set_hp(new : int) -> void:
	_health = new

func decrease_hp(amount : int) -> void:
	set_hp(get_hp() - amount)

func increase_hp(amount : int) -> void:
	set_hp(get_hp() + amount)

# ----- HEAT -----

func get_heat() -> int:
	return _heat

func set_heat(new : int) -> void:
	_heat = new

func decrease_heat(amount : int) -> void:
	set_heat(get_heat() - amount)

func increase_heat(amount : int) -> void:
	set_heat(get_heat() + amount)

# ----- DISPLAY NAME -----

func display_name() -> String: return _name
