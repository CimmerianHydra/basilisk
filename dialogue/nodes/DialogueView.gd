class_name DialogueView
extends Control

## Default letter reveal rate, used when a LineEvent doesn't specify one.
@export var default_letters_per_second: float = 30.0

## Modulate colors applied to characters based on whether they're speaking.
@export var speaker_modulate: Color = Color.WHITE
@export var non_speaker_modulate: Color = Color(0.5, 0.5, 0.5, 1.0)
@export var modulate_tween_duration: float = 0.2

## Sub-component references. Wired in the concrete scene's inspector.
@export var text_box: DialogueTextBox
@export var character_stage: CharacterStage
@export var background_layer: BackgroundLayer
@export var foreground_layer: ForegroundLayer
@export var music_controller: MusicController

## Optional: a Label or RichTextLabel that displays the current speaker's name.
## Left null if the concrete view doesn't have one.
@export var name_tag: Control


func _ready() -> void:
	_validate_components()


func _validate_components() -> void:
	if text_box == null:
		push_error("DialogueView '%s' has no text_box assigned." % name)
	if character_stage == null:
		push_error("DialogueView '%s' has no character_stage assigned." % name)
	if background_layer == null:
		push_warning("DialogueView '%s' has no background_layer assigned. Background events will be ignored." % name)
	if music_controller == null:
		push_warning("DialogueView '%s' has no music_controller assigned. Music events will be ignored." % name)


# --- Event handlers (called by DialoguePlayer) ---

# dialogue_view.gd — updated show_line
func show_line(event: LineEvent) -> void:
	_apply_mood_overrides(event)
	_update_speaker_highlighting(event.speakers)
	_update_name_tag(event.speakers)

	var rate := event.letters_per_second if event.letters_per_second > 0.0 else default_letters_per_second
	await text_box.show_line(
		event.text,
		rate,
		event.auto_advance_delay,
		event.clear_behavior,
		event.speakers
	)


func character_enter(event: CharacterEnterEvent) -> void:
	if character_stage == null:
		return
	await character_stage.add_character(
		event.character,
		event.side,
		event.flip,
		event.position_ratio,
		event.z_index,
		event.mood,
		event.fade_duration,
		non_speaker_modulate
	)


func character_exit(event: CharacterExitEvent) -> void:
	if character_stage == null:
		return
	await character_stage.remove_character(event.character, event.fade_duration)


func character_move(event: CharacterMoveEvent) -> void:
	if character_stage == null:
		return
	await character_stage.move_character(
		event.character,
		event.side,
		event.position_ratio,
		event.z_index,
		event.duration
	)


func character_mood(event: CharacterMoodEvent) -> void:
	if character_stage == null:
		return
	await character_stage.set_mood(event.character, event.mood, event.transition_duration)


func change_background(event: BackgroundChangeEvent) -> void:
	if background_layer == null:
		return
	await background_layer.change_to(event.texture, event.crossfade_duration)

func change_foreground(event: ForegroundChangeEvent) -> void:
	if background_layer == null:
		return
	await foreground_layer.change_to(event.texture, event.crossfade_duration)


func change_music(event: MusicChangeEvent) -> void:
	if music_controller == null:
		return
	await music_controller.change_to(event.stream, event.fade_duration, event.volume_db)

func change_stage_modulate(event: StageModulateChangeEvent) -> void:
	if character_stage == null:
		return
	var target = event.target_color
	var duration = event.duration
	await character_stage.set_stage_modulate(target, duration)

func clear_text_box(event: ClearTextBoxEvent) -> void:
	if text_box == null:
		return
	await text_box.clear(event.fade_duration)

# --- Helpers ---

func _apply_mood_overrides(event: LineEvent) -> void:
	if character_stage == null:
		return
	for character: CharacterDefinition in event.mood_overrides:
		var mood: String = event.mood_overrides[character]
		# Fire-and-forget; we don't await mood changes triggered by a line,
		# because the line should start revealing text immediately.
		character_stage.set_mood(character, mood, modulate_tween_duration)


func _update_speaker_highlighting(speakers: Array[CharacterDefinition]) -> void:
	if character_stage == null:
		return
	character_stage.set_speakers(speakers, speaker_modulate, non_speaker_modulate, modulate_tween_duration)


func _update_name_tag(speakers: Array[CharacterDefinition]) -> void:
	if name_tag == null:
		return

	if speakers.is_empty():
		# Narrator line — hide the tag.
		name_tag.visible = false
		return

	name_tag.visible = true
	# Build a combined name like "Alice & Bob" for multi-speaker lines.
	var names: Array[String] = []
	for character in speakers:
		names.append(character.display_name)
	var combined := " & ".join(names)

	# The name_tag could be either a Label or a RichTextLabel.
	# Handle both, using the first speaker's color as the tint.
	var color: Color = speakers[0].name_color
	if name_tag is RichTextLabel:
		(name_tag as RichTextLabel).text = "[color=#%s]%s[/color]" % [color.to_html(false), combined]
	elif name_tag is Label:
		(name_tag as Label).text = combined
		(name_tag as Label).modulate = color
