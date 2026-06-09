extends Control
class_name DiceRoller

const GROUP: StringName = &"dice_roller"

@export var face_label: Label
@export var tumble_steps: int = 14
@export var start_delay: float = 0.03
@export var delay_growth: float = 1.18
@export var crit_color: Color = Color(1, 0.85, 0.2)
@export var fumble_color: Color = Color(1, 0.3, 0.3)

func _ready() -> void:
	add_to_group(GROUP)
	visible = false

func roll(sides: int, result: int) -> void:
	visible = true
	modulate = Color.WHITE
	scale = Vector2.ONE
	face_label.modulate = Color.BLACK

	var delay := start_delay
	for i in tumble_steps:
		face_label.text = str(randi_range(1, sides))
		rotation = randf_range(-0.15, 0.15)   # a little jitter
		await get_tree().create_timer(delay).timeout
		delay *= delay_growth

	rotation = 0.0
	face_label.text = str(result)
	if result == sides:
		face_label.modulate = crit_color
	elif result == 1:
		face_label.modulate = fumble_color

	var punch := create_tween()
	punch.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	punch.tween_property(self, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	await punch.finished

	await get_tree().create_timer(0.5).timeout
	var fade := create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.2)
	await fade.finished
	visible = false
