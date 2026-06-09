class_name MusicChangeEvent
extends DialogueEvent

## Set to null to fade out music with no replacement.
@export var stream: AudioStream
@export var fade_duration: float = 1.0
@export_range(-80.0, 6.0) var volume_db: float = 0.0
