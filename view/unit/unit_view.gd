class_name UnitView
extends Node3D

## Visual proxy for one model Unit. The scene (unit_view.tscn) owns the structure —
## placeholder capsule, highlight ring, pick area; this script owns the behavior:
## faction tinting, selectability, and click reporting. Holds a reference to its
## Unit; the Unit never knows the view exists.
##
## Instantiate via the scene, then call setup() BEFORE adding to the tree so the
## faction color can be applied on ready.

signal clicked(unit: Unit)

const PLAYER_COLOR := Color(0.25, 0.45, 0.85)
const ENEMY_COLOR := Color(0.85, 0.30, 0.25)

var unit: Unit

var _selectable := false

@onready var _body: MeshInstance3D = $Body
@onready var _highlight: MeshInstance3D = $Highlight
@onready var _pick_area: Area3D = $PickArea


func setup(p_unit: Unit) -> void:
	unit = p_unit
	name = "UnitView_%s" % p_unit.display_name().replace(" ", "_")


func _ready() -> void:
	_apply_faction_color()
	_pick_area.input_event.connect(_on_input_event)
	_pick_area.mouse_entered.connect(_on_mouse_entered)
	_pick_area.mouse_exited.connect(_on_mouse_exited)
	_highlight.visible = false


## Marks this unit as a valid option: shows the ring and accepts clicks.
func set_selectable(value: bool) -> void:
	_selectable = value
	_highlight.visible = value
	_highlight.scale = Vector3.ONE


func _apply_faction_color() -> void:
	if unit == null:
		push_warning("UnitView entered the tree without setup(); no faction color applied.")
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = PLAYER_COLOR if unit._faction == Unit.Faction.PLAYER else ENEMY_COLOR
	_body.material_override = material


func _on_input_event(_camera: Node, event: InputEvent,
		_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not _selectable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(unit)


func _on_mouse_entered() -> void:
	if _selectable:
		_highlight.scale = Vector3(1.25, 1.0, 1.25)


func _on_mouse_exited() -> void:
	_highlight.scale = Vector3.ONE
