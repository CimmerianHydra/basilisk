class_name CharacterDefinition
extends Resource

@export var display_name: String = ""
@export var name_color: Color = Color.WHITE

## Maps a mood name (e.g. "neutral", "angry", "sad") to a sprite texture.
## "neutral" is treated as the default if present.
@export var mood_sprites: Dictionary[String, Texture2D] = {}

## Default side this character appears on when entering the stage.
@export_enum("left", "right") var default_side: String = "left"


func get_mood_texture(mood: String) -> Texture2D:
	if mood in mood_sprites:
		return mood_sprites[mood]
	if "neutral" in mood_sprites:
		push_warning("Mood '%s' not found on '%s', falling back to 'neutral'." % [mood, display_name])
		return mood_sprites["neutral"]
	push_warning("No moods defined on '%s'." % display_name)
	return null
