class_name RadialChoicePanel
extends Control

## Radial flavour: buttons distributed on a circle around screen centre, prompt at
## the top of the screen. On present() the buttons spawn stacked at the centre and
## slide outward to their slots; on selection they slide back in and fade before
## the choice is reported. Because selected only fires after the exit animation,
## anything awaiting it naturally waits the animation out.

signal selected(index: int)

@export var circle_radius: float = 180.0
@export var slide_duration: float = 0.35
@export var stagger: float = 0.05

@onready var _title: Label = $Title
var _buttons: Array[Button] = []
var _tween: Tween


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# The panel itself must never eat clicks meant for the 3D scene; only the
	# buttons (which stop input themselves) are interactive.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func present(title: String, labels: Array[String]) -> void:
	_kill_tween()
	_clear()

	_title.text = title
	_title.modulate.a = 0.0
	visible = true

	for i in labels.size():
		var button := Button.new()
		button.text = labels[i]
		button.disabled = true      # No clicks while the pile is still overlapping.
		button.modulate.a = 0.0
		button.pressed.connect(_choose.bind(i))
		add_child(button)
		_buttons.append(button)

	# Buttons size themselves from their text during the next layout pass; wait
	# one frame so `button.size` is real before we place anything.
	await get_tree().process_frame

	var centre := size * 0.5
	for button in _buttons:
		button.reset_size()
		button.position = centre - button.size * 0.5

	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_title, "modulate:a", 1.0, slide_duration)
	for i in _buttons.size():
		var button := _buttons[i]
		var target := centre + _slot_offset(i, _buttons.size()) - button.size * 0.5
		_tween.tween_property(button, "position", target, slide_duration) \
				.set_delay(i * stagger) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_tween.tween_property(button, "modulate:a", 1.0, slide_duration * 0.6) \
				.set_delay(i * stagger)
	await _tween.finished

	for button in _buttons:
		button.disabled = false


## Slot i of n on the circle, starting at the top and going clockwise.
func _slot_offset(index: int, count: int) -> Vector2:
	var angle := -PI / 2.0 + TAU * float(index) / float(count) - TAU/4
	return Vector2(cos(angle), sin(angle)) * circle_radius


func _choose(index: int) -> void:
	for button in _buttons:
		button.disabled = true
	await _play_exit()
	visible = false
	_clear()
	selected.emit(index)


## The enter animation in reverse: slide back to centre, accelerating, and fade.
func _play_exit() -> void:
	_kill_tween()
	var centre := size * 0.5
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_title, "modulate:a", 0.0, slide_duration)
	for i in _buttons.size():
		var button := _buttons[i]
		_tween.tween_property(button, "position", centre - button.size * 0.5, slide_duration) \
				.set_delay(i * stagger) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		_tween.tween_property(button, "modulate:a", 0.0, slide_duration * 0.8) \
				.set_delay(i * stagger)
	await _tween.finished


func _clear() -> void:
	for button in _buttons:
		button.queue_free()
	_buttons.clear()


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
