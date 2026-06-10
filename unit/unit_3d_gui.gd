extends Control
class_name Unit3DGUI

@export var z_offset : float = 0.0

@onready var camera := get_viewport().get_camera_3d()
@onready var unit : Unit = get_parent()
@onready var label: Label = $VBoxContainer/PanelContainer/HBoxContainer/Label
@onready var unit_display = $VBoxContainer/PanelContainer/HBoxContainer/UnitDisplay
@onready var health_progress: ProgressBar = $VBoxContainer/HealthGUI/HBoxContainer/ProgressBar
@onready var heat_progress: ProgressBar = $VBoxContainer/HeatGUI/HBoxContainer/ProgressBar
@onready var structure_amount: Label = $VBoxContainer/StructureGUI/HBoxContainer/StructureAmount

func _ready() -> void:
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	label.text = unit.name
	unit_display.texture = unit.display_icon
	health_progress.max_value = unit.health_component.max_health
	heat_progress.max_value = unit.heat_component.max_heat
	structure_amount.text = str(unit.health_component.structure)
	update_all()

func _process(_delta: float) -> void:
	if not camera.current:
		# If the camera we have isn't the current one, get the current camera.
		camera = get_viewport().get_camera_3d()

	var parent_position: Vector3 = unit.global_transform.origin
	var camera_transform := camera.global_transform
	var camera_position := camera_transform.origin
	var spatial_position := parent_position + Vector3.UP * z_offset

	# We would use "camera.is_position_behind(parent_position)", except
	# that it also accounts for the near clip plane, which we don't want.
	var is_behind := camera_transform.basis.z.dot(spatial_position - camera_position) > 0

	# Fade the waypoint when the camera gets close.
	var distance := camera_position.distance_to(spatial_position)
	modulate.a = clamp(remap(distance, 0, 2, 0, 1), 0, 1 )

	var unprojected_position := camera.unproject_position(spatial_position)

	position = unprojected_position
	visible = not is_behind

func update_all() -> void:
	_update_health_progressbar()
	_update_heat_progressbar()
	_update_structure_amount()

func _update_health_progressbar() -> void:
	health_progress.value = unit.health_component.get_current_health()

func _update_heat_progressbar() -> void:
	heat_progress.value = unit.heat_component.get_current_heat()

func _update_structure_amount() -> void:
	structure_amount.text = str(unit.health_component.get_current_structure())
