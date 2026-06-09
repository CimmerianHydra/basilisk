extends Control

@export var turn_state : TurnState
@export var unit_roster : UnitRoster
@export var event_bus : EventBus

var _last_clicked_unit : Unit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	turn_state.connect("state_entered", _on_state_entered)
	unit_roster.connect("unit_clicked", _on_unit_clicked)
	GlobalSignals.connect("action_completed", _on_action_completed)

func _on_state_entered(state_name : String):
	match state_name:
		"PlayerTurn": visible = true
		_: visible = false

func _on_unit_clicked(unit : Unit):
	var current_state = turn_state.get_current_state()
	match current_state.name:
		"PlayerTurn":
			_last_clicked_unit = unit
			_refresh_display()
		_: return

func _on_action_completed(_action : Action):
	_refresh_display()

## Generates the buttons for the unit UI, starting from its ActionLibrary.
func _refresh_display() -> void:
	clear_buttons()
	set_unit_display(_last_clicked_unit)
	if _last_clicked_unit.team == Unit.TEAM.ALLIES:
		add_buttons_from_unit(_last_clicked_unit)

# --------- UNIT DISPLAY GUI --------- #

@onready var _unit_display_label = $ButtonsPanel/UnitDisplay/UnitDisplay/Label
@onready var _unit_display_texture = $ButtonsPanel/UnitDisplay/UnitDisplay/TextureRect

func set_unit_display(unit : Unit):
	_unit_display_label.text = unit.name
	_unit_display_texture.texture = unit.display_icon

# --------- BUTTON DISPLAY GUI --------- #

@onready var _buttons_container = $ButtonsPanel/ButtonsContainer

func add_buttons_from_unit(unit: Unit):
	for def_act_pair in unit.action_library.get_button_definitions_and_actions():
		var definition = def_act_pair[0]
		var action = def_act_pair[1]
		add_button(definition, action)

# Adds a unique action button
func add_button(def : ButtonDefinition, action : Action):
	var button := Button.new()
	button.text = def.text
	button.icon = def.icon
	button.connect("pressed", func(): action.run())
	_buttons_container.add_child(button)

func clear_buttons():
	for button in _buttons_container.get_children():
		button.queue_free()
