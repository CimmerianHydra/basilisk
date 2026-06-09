class_name CharacterMoveEvent
extends DialogueEvent

@export var character: CharacterDefinition
@export_enum("left", "right") var side: String = "left"
@export var position_ratio: float = 0.5
@export var z_index: int = 0
@export var duration: float = 0.3
