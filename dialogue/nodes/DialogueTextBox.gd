class_name DialogueTextBox
extends Control

## The RichTextLabel that displays the text. Wire in the inspector.
@export var rich_text_label: RichTextLabel

## Optional: a node shown when the line is fully revealed and waiting for input
## (the little blinking arrow you see in most VNs). Visibility is toggled
## automatically; animate it however you like in its own script.
@export var continue_indicator: Control

## A hidden RichTextLabel used to measure whether text would overflow.
## Should be a sibling of rich_text_label with identical font/width settings,
## visible = false, and mouse_filter = MOUSE_FILTER_IGNORE.
@export var measurement_probe: RichTextLabel

enum _State { IDLE, REVEALING, WAITING_FOR_ADVANCE }

var _state: _State = _State.IDLE
var _letters_per_second: float = 40.0
var _reveal_accumulator: float = 0.0
var _reveal_start_chars: int = 0
var _total_visible_chars: int = 0
var _auto_advance_delay: float = 0.0
var _auto_advance_elapsed: float = 0.0

var _last_speakers: Array[CharacterDefinition] = []
var _current_text: String = ""

func _ready() -> void:
	if rich_text_label == null:
		push_error("DialogueTextBox has no RichTextLabel assigned.")
		return
	rich_text_label.bbcode_enabled = true
	rich_text_label.visible_characters_behavior = TextServer.VC_CHARS_BEFORE_SHAPING
	rich_text_label.visible_characters = 0
	if measurement_probe:
		measurement_probe.bbcode_enabled = true
		measurement_probe.visible = false
		measurement_probe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if continue_indicator:
		continue_indicator.visible = false
	set_process(false)
	set_process_input(false)


func show_line(
	text: String,
	letters_per_second: float,
	auto_advance_delay: float,
	clear_behavior: LineEvent.ClearBehavior,
	speakers: Array[CharacterDefinition]
) -> void:
	if rich_text_label == null:
		return

	var should_clear := await _should_clear_for(text, clear_behavior, speakers)
	if should_clear:
		_current_text = ""
		_reveal_start_chars = 0
	else:
		_reveal_start_chars = _current_text.length()

	# Separator between appended lines.
	var separator := " " if (not should_clear and _current_text != "") else ""
	_current_text = _current_text + separator + text

	rich_text_label.text = _current_text
	rich_text_label.visible_characters = _reveal_start_chars
	await get_tree().process_frame
	_total_visible_chars = rich_text_label.get_total_character_count()

	_letters_per_second = letters_per_second
	_auto_advance_delay = auto_advance_delay
	_auto_advance_elapsed = 0.0
	_reveal_accumulator = float(_reveal_start_chars)
	_last_speakers = speakers.duplicate()

	if continue_indicator:
		continue_indicator.visible = false

	_state = _State.REVEALING
	set_process(true)
	set_process_input(true)

	while _state != _State.IDLE:
		await get_tree().process_frame


func clear(fade_duration: float) -> void:
	if rich_text_label == null:
		return
	if fade_duration > 0.0 and rich_text_label.text != "":
		var tween := create_tween()
		tween.tween_property(rich_text_label, "modulate:a", 0.0, fade_duration)
		await tween.finished
	rich_text_label.text = ""
	rich_text_label.visible_characters = 0
	rich_text_label.modulate.a = 1.0
	_current_text = ""
	_last_speakers = []


# --- Decision logic ---

func _should_clear_for(
	new_text: String,
	behavior: LineEvent.ClearBehavior,
	speakers: Array[CharacterDefinition]
) -> bool:
	match behavior:
		LineEvent.ClearBehavior.CLEAR:
			return true
		LineEvent.ClearBehavior.APPEND:
			return await _would_overflow(new_text)
		LineEvent.ClearBehavior.AUTO, _:
			if _speakers_differ(speakers, _last_speakers):
				return true
			return await _would_overflow(new_text)


func _speakers_differ(a: Array[CharacterDefinition], b: Array[CharacterDefinition]) -> bool:
	if a.size() != b.size():
		return true
	for character in a:
		if not character in b:
			return true
	return false


func _would_overflow(new_text: String) -> bool:
	if measurement_probe == null:
		# No probe configured — assume no overflow and let the user notice.
		return false
	if _current_text == "":
		# Nothing to append to; can't overflow by appending.
		return false

	# Match probe width to the real label so wrapping behaves identically.
	measurement_probe.custom_minimum_size.x = rich_text_label.size.x
	measurement_probe.size.x = rich_text_label.size.x
	measurement_probe.text = _current_text + "\n" + new_text
	await get_tree().process_frame
	return measurement_probe.get_content_height() > rich_text_label.size.y


# --- Typewriter & input (mostly unchanged) ---

func _process(delta: float) -> void:
	match _state:
		_State.REVEALING:
			_reveal_accumulator += delta * _letters_per_second
			var new_visible := int(_reveal_accumulator)
			if new_visible >= _total_visible_chars:
				rich_text_label.visible_characters = _total_visible_chars
				_enter_waiting_state()
			else:
				rich_text_label.visible_characters = new_visible

		_State.WAITING_FOR_ADVANCE:
			if _auto_advance_delay > 0.0:
				_auto_advance_elapsed += delta
				if _auto_advance_elapsed >= _auto_advance_delay:
					_advance()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	match _state:
		_State.REVEALING:
			rich_text_label.visible_characters = _total_visible_chars
			_enter_waiting_state()
			get_viewport().set_input_as_handled()
		_State.WAITING_FOR_ADVANCE:
			_advance()
			get_viewport().set_input_as_handled()


func _enter_waiting_state() -> void:
	_state = _State.WAITING_FOR_ADVANCE
	_auto_advance_elapsed = 0.0
	if continue_indicator:
		continue_indicator.visible = true


func _advance() -> void:
	_state = _State.IDLE
	set_process(false)
	set_process_input(false)
	if continue_indicator:
		continue_indicator.visible = false
