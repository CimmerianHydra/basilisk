class_name MusicController
extends Node

@export var player_a: AudioStreamPlayer
@export var player_b: AudioStreamPlayer

## Volume considered "silent" for fade purposes. -80 is Godot's effective mute.
const SILENT_DB: float = -80.0

var _active: AudioStreamPlayer
var _inactive: AudioStreamPlayer


func _ready() -> void:
	if player_a == null or player_b == null:
		push_error("MusicController needs both player_a and player_b assigned.")
		return
	_active = player_a
	_inactive = player_b
	_active.volume_db = SILENT_DB
	_inactive.volume_db = SILENT_DB


func change_to(stream: AudioStream, fade_duration: float, target_volume_db: float) -> void:
	# Case: fade to silence (stream is null).
	if stream == null:
		if not _active.playing:
			return
		if fade_duration <= 0.0:
			_active.stop()
			return
		var fade_out := create_tween()
		fade_out.tween_property(_active, "volume_db", SILENT_DB, fade_duration)
		await fade_out.finished
		_active.stop()
		return

	# Case: same stream already playing, just retarget volume.
	if _active.stream == stream and _active.playing:
		if fade_duration <= 0.0:
			_active.volume_db = target_volume_db
		else:
			var retarget := create_tween()
			retarget.tween_property(_active, "volume_db", target_volume_db, fade_duration)
			await retarget.finished
		return

	# Case: crossfade to new stream.
	_inactive.stream = stream
	_inactive.volume_db = SILENT_DB
	_inactive.play()

	if fade_duration <= 0.0:
		_active.stop()
		_inactive.volume_db = target_volume_db
	else:
		var tween := create_tween().set_parallel(true)
		tween.tween_property(_active, "volume_db", SILENT_DB, fade_duration)
		tween.tween_property(_inactive, "volume_db", target_volume_db, fade_duration)
		await tween.finished
		_active.stop()

	var tmp := _active
	_active = _inactive
	_inactive = tmp
