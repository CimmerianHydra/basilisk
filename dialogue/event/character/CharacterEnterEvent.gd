class_name CharacterEnterEvent
extends DialogueEvent

@export var character: CharacterDefinition
@export_enum("left", "right") var side: String = "left"
@export var flip: bool = false

## Horizontal position within the side, 0.0 (edge) to 1.0 (center).
## The view interprets this however it wants.
@export var position_ratio: float = 0.5
@export var z_index: int = 0
@export var mood: String = "neutral"
@export var fade_duration: float = 0.3
