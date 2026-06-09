class_name DialoguePlayer
extends Node

## Emitted when a sequence finishes playing all events.
signal sequence_finished(sequence: DialogueSequence)

## Emitted right before each event is dispatched. Useful for debugging or save points.
signal event_started(event: DialogueEvent, index: int)

## The view that renders dialogue. Must extend DialogueView.
## Assigned via the inspector or set in code before calling play().
@export var view: DialogueView

var _current_sequence: DialogueSequence = null
var _current_index: int = -1
var _is_playing: bool = false
var _stop_requested: bool = false


func play(sequence: DialogueSequence) -> void:
	if _is_playing:
		push_error("DialoguePlayer is already playing a sequence.")
		return
	if view == null:
		push_error("DialoguePlayer has no view assigned.")
		return
	if sequence == null or sequence.events.is_empty():
		push_warning("DialoguePlayer.play() called with an empty or null sequence.")
		return

	_current_sequence = sequence
	_current_index = -1
	_is_playing = true
	_stop_requested = false

	await _run()

	_is_playing = false
	var finished_sequence := _current_sequence
	_current_sequence = null
	_current_index = -1
	sequence_finished.emit(finished_sequence)


func stop() -> void:
	_stop_requested = true


func is_playing() -> bool:
	return _is_playing


func _run() -> void:
	for i in _current_sequence.events.size():
		if _stop_requested:
			return
		_current_index = i
		var event := _current_sequence.events[i]
		event_started.emit(event, i)
		await _dispatch(event)


func _dispatch(event: DialogueEvent) -> void:
	if event is LineEvent:
		await view.show_line(event)
	elif event is CharacterEnterEvent:
		await view.character_enter(event)
	elif event is CharacterExitEvent:
		await view.character_exit(event)
	elif event is CharacterMoveEvent:
		await view.character_move(event)
	elif event is CharacterMoodEvent:
		await view.character_mood(event)
	elif event is BackgroundChangeEvent:
		await view.change_background(event)
	elif event is ForegroundChangeEvent:
		await view.change_foreground(event)
	elif event is StageModulateChangeEvent:
		await view.change_stage_modulate(event)
	elif event is MusicChangeEvent:
		await view.change_music(event)
	elif event is WaitEvent:
		await get_tree().create_timer(event.duration).timeout
	elif event is ClearTextBoxEvent:
		await view.clear_text_box(event)
	else:
		push_warning("Unhandled event type: %s" % event.get_class())
