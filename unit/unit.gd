extends Node3D
class_name Unit

enum TEAM {
	HOSTILES,
	ALLIES,
	OTHER
}

signal clicked

@export_category("Game Mechanics")
@export var team := Unit.TEAM.ALLIES

@export_category("GUI")
@export var display_icon := Texture2D

@export_category("Components")
@export var action_library : ActionLibrary
@export var resource_library : BattleResourceLibrary
@export var status_effect_container : Node
@export var grid_position_component : GridPositionComponent
@export var move_component : MoveComponent
@export var health_component : HealthComponent
@export var heat_component : HeatComponent


func take_damage(damage : Dmg) -> void:
	$AnimationPlayer.play("shake")
	await $AnimationPlayer.animation_finished
	health_component.take_damage(damage)
	$Unit3DGUI.update_all()

func take_heat(amount : int) -> void:
	$AnimationPlayer.play("shake")
	await $AnimationPlayer.animation_finished
	heat_component.take_heat(amount)
	$Unit3DGUI.update_all()

func destroy() -> void:
	$AnimationPlayer.play("shake", -1, 0.5)
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_clickable_component_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()

func set_clickable(value: bool) -> void:
	$ClickableComponent.visible = value

func highlight_start() -> void:
	$TargetingVisual.visible = true

func highlight_stop() -> void:
	$TargetingVisual.visible = false


func _on_health_component_destroyed() -> void:
	destroy()
