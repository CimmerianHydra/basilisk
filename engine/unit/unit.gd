extends RefCounted
class_name Unit

enum Faction { PLAYER, ENEMY }

@export var _name : String
@export var _frame : FrameDefinition

## BATTLE STATE
var _hp : int = 0 # Health Points
var _tp : int = 0 # HeaT Points
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

## MODIFIERS
var _modifiers : Array[Modifier]

## TRAITS
var _trait

func _init(name, frame : FrameDefinition = FrameDefinition.new()) -> void:
	_name = name
	_frame = frame
	_hp = frame.max_hp

# ----- BATTLE ENGINE SETTERS AND GETTERS -----

func set_controller(controller : Controller) -> void:
	_controller = controller

func add_weapon(definition : WeaponDefinition) -> void:
	var w = Weapon.new(definition)
	_weapons.append(w)

func add_modifier(mod : Modifier) -> void:
	_modifiers.append(mod)

func get_modifiers() -> Array[Modifier]:
	# Clean up first so we never hand over expired mods
	for mod in _modifiers.duplicate():
		if mod._ticks == 0: _modifiers.erase(mod)
	return _modifiers

func available_actions() -> Array[BattleAction]:
	var general_actions : Array[BattleAction] = [
		Skirmish.new(self),
		QuickTech.new(self),
		Boost.new(self),
		GiveLockOn.new(self),
		EndTurnAction.new(self)
		]
	if _controller is HumanController:
		general_actions.append_array([
			Overcharge.new(self),
			])
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
	return _hp

func set_hp(new : int) -> void:
	_hp = new

func decrease_hp(amount : int) -> void:
	set_hp(get_hp() - amount)

func increase_hp(amount : int) -> void:
	set_hp(get_hp() + amount)

# ----- HEAT -----

func get_heat() -> int:
	return _hp

func set_heat(new : int) -> void:
	_hp = new

func decrease_heat(amount : int) -> void:
	set_heat(get_heat() - amount)

func increase_heat(amount : int) -> void:
	set_heat(get_heat() + amount)

# ----- DISPLAY NAME -----

func display_name() -> String: return _name
