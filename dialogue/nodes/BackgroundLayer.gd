class_name BackgroundLayer
extends Control

@export var texture_rect_a: TextureRect
@export var texture_rect_b: TextureRect

var _active: TextureRect
var _inactive: TextureRect


func _ready() -> void:
	if texture_rect_a == null or texture_rect_b == null:
		push_error("BackgroundLayer needs both texture_rect_a and texture_rect_b assigned.")
		return
	_active = texture_rect_a
	_inactive = texture_rect_b
	_inactive.modulate.a = 0.0


func change_to(new_texture: Texture2D, crossfade_duration: float) -> void:
	if _active == null:
		return
	_inactive.texture = new_texture
	_inactive.modulate.a = 0.0

	if crossfade_duration <= 0.0:
		_active.modulate.a = 0.0
		_inactive.modulate.a = 1.0
	else:
		var tween := create_tween().set_parallel(true)
		tween.tween_property(_active, "modulate:a", 0.0, crossfade_duration)
		tween.tween_property(_inactive, "modulate:a", 1.0, crossfade_duration)
		await tween.finished

	# Swap roles.
	var tmp := _active
	_active = _inactive
	_inactive = tmp
