class_name CharacterStage
extends Control

## Vertical position where character sprites are anchored, as a ratio of stage height.
## 0.5 = vertically centered; 0.7 = lower-middle, typical for talking-head VNs.
@export var vertical_anchor_ratio: float = 0.6

## How far from the edge of each side characters can be placed.
## 0.0 = can touch the edge; 0.2 = stays within the inner 80% of each side.
@export var horizontal_margin_ratio: float = 0.1

## Character sprite height as a fraction of stage height.
## 1.0 = sprite fills the stage vertically; 0.9 leaves a little headroom.
@export_range(0.1, 1.0) var sprite_height_ratio: float = 1.0

var _displays: Dictionary[CharacterDefinition, CharacterDisplay] = {}

func _ready() -> void:
	resized.connect(_on_stage_resized)


func _on_stage_resized() -> void:
	for character: CharacterDefinition in _displays:
		var display := _displays[character]
		display.fit_to_height(size.y * sprite_height_ratio)
		# Each display's own `resized` signal handles repositioning.


func _on_display_resized(display: CharacterDisplay) -> void:
	if not is_instance_valid(display):
		return
	display.position = _compute_position(display, display.side, display.position_ratio)


func remove_character(character: CharacterDefinition, fade_duration: float) -> void:
	if not character in _displays:
		return
	var display := _displays[character]
	_displays.erase(character)

	var faded := display.modulate
	faded.a = 0.0
	display.tween_modulate(faded, fade_duration)
	if fade_duration > 0.0:
		await get_tree().create_timer(fade_duration).timeout
	display.queue_free()


func add_character(
	character: CharacterDefinition,
	side: String,
	flip: bool,
	position_ratio: float,
	z_index_value: int,
	mood: String,
	fade_duration: float,
	initial_modulate: Color
) -> void:
	if character in _displays:
		push_warning("Character '%s' is already on stage." % character.display_name)
		return

	var display := CharacterDisplay.new()
	add_child(display)
	var transparent := initial_modulate
	transparent.a = 0.0
	display.setup(character, side, flip, position_ratio, z_index_value, mood, transparent)
	# Connect first so the initial fit_to_height fires the reposition.
	display.resized.connect(_on_display_resized.bind(display))
	display.fit_to_height(size.y * sprite_height_ratio)
	_displays[character] = display

	display.tween_modulate(initial_modulate, fade_duration)
	if fade_duration > 0.0:
		await get_tree().create_timer(fade_duration).timeout


func move_character(
	character: CharacterDefinition,
	side: String,
	position_ratio: float,
	z_index_value: int,
	duration: float
) -> void:
	if not character in _displays:
		push_warning("Cannot move '%s': not on stage." % character.display_name)
		return
	var display := _displays[character]
	display.side = side
	display.position_ratio = position_ratio
	var target := _compute_position(display, side, position_ratio)
	display.tween_to_position(target, z_index_value, duration)
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout


func set_mood(character: CharacterDefinition, mood: String, duration: float) -> void:
	if not character in _displays:
		return
	var display := _displays[character]
	display.tween_to_mood(mood, duration)
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout


func set_speakers(
	speakers: Array[CharacterDefinition],
	speaker_modulate: Color,
	non_speaker_modulate: Color,
	duration: float
) -> void:
	for character: CharacterDefinition in _displays:
		var display := _displays[character]
		var target: Color = speaker_modulate if character in speakers else non_speaker_modulate
		display.tween_modulate(target, duration)

func set_stage_modulate(
	target: Color,
	duration: float
) -> void:
	var modulate_tween = create_tween()
	modulate_tween.tween_property(self, "modulate", target, duration)

func _compute_position(display: CharacterDisplay, side: String, position_ratio: float) -> Vector2:
	var stage_size := size
	var sprite_size := display.size

	var usable_width := stage_size.x * 0.5 * (1.0 - horizontal_margin_ratio * 2.0)
	var side_center_x: float
	if side == "left":
		# position_ratio 0.0 = far left edge, 1.0 = center of screen
		var inner_edge := stage_size.x * horizontal_margin_ratio
		side_center_x = inner_edge + position_ratio * usable_width
	else:
		# position_ratio 0.0 = far right edge, 1.0 = center of screen
		var inner_edge := stage_size.x * (1.0 - horizontal_margin_ratio)
		side_center_x = inner_edge - position_ratio * usable_width

	var y := stage_size.y * vertical_anchor_ratio
	return Vector2(side_center_x - sprite_size.x * 0.5, y - sprite_size.y * 0.5)
