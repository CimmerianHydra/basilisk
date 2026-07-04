extends RefCounted
class_name Unit

enum Faction { PLAYER, ENEMY }

@export var _name : String
@export var _frame : FrameDefinition

## BATTLE STATE
var _hp : int = 0 # Health Points
var _tp : int = 0 # HeaT Points
var _weapons : Array[WeaponDefinition] = []
var _position : Vector3i = Vector3i.ZERO

## CONTROLLER
var _controller : Controller
var _faction := Faction.PLAYER

## ACTION ECONOMY
var _activations : int = 1
var _quick_actions : int = 2

## MODIFIERS
var _modifiers : Array[Modifier]

func _init(name, frame : FrameDefinition = FrameDefinition.new()) -> void:
	_name = name
	_frame = frame
	_hp = frame.max_hp

func set_controller(controller : Controller) -> void:
	_controller = controller

func available_actions() -> Array[BattleAction]:
	var general_actions : Array[BattleAction] = []
	if _controller is HumanController:
		general_actions = [
			Skirmish.new(self),
			QuickTech.new(self),
			Overcharge.new(self),
			GiveLockOn.new(self),
			EndTurnAction.new(self)
			]
	else:
		general_actions = [
			Skirmish.new(self),
			QuickTech.new(self),
			GiveLockOn.new(self),
			EndTurnAction.new(self)
			]
	return general_actions

func get_evasion() -> int:
	return _frame.evasion

func get_e_defense() -> int:
	return _frame.e_defense

func get_armor() -> int:
	return _frame.armor


func get_hp() -> int:
	return _hp

func set_hp(new : int) -> void:
	_hp = new

func apply_damage(amount : int, type : Damage.Type) -> void:
	amount -= get_armor()
	set_hp(get_hp() - amount)
	print("Unit %s took %s %s damage." % [_name, amount, Damage.display_name(type)])



func add_modifier(mod : Modifier) -> void:
	_modifiers.append(mod)

func get_modifiers() -> Array[Modifier]:
	# Clean up first so we never hand over expired mods
	for mod in _modifiers.duplicate():
		if mod._ticks == 0: _modifiers.erase(mod)
	return _modifiers

func display_name() -> String: return _name
