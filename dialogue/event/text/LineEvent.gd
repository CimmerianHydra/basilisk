class_name LineEvent
extends DialogueEvent

## Characters considered "speaking" this line. Empty = narrator (no one highlighted).
@export var speakers: Array[CharacterDefinition] = []

## BBCode-supporting text. Use [color], [shake], [wave], etc.
@export_multiline var text: String = ""

## Letters revealed per second. 0 or negative = use the view's default.
@export var letters_per_second: float = 0.0

## If > 0, line auto-advances after this many seconds following full reveal,
## with no ui_accept press required. 0 = wait for input.
@export var auto_advance_delay: float = 0.0

## Optional mood overrides applied when this line starts.
## Keys are CharacterDefinition resources; values are mood names.
@export var mood_overrides: Dictionary[CharacterDefinition, String] = {}

## How this line interacts with whatever is already in the textbox.
## AUTO = clear if speaker changed or text would overflow.
## CLEAR = always clear before showing.
## APPEND = append; only clears if it would overflow.
enum ClearBehavior { AUTO, CLEAR, APPEND }
@export var clear_behavior: ClearBehavior = ClearBehavior.AUTO
