class_name CharacterDisplay
extends TextureRect

var character: CharacterDefinition
var side: String = "left"
var position_ratio: float = 0.5

var _modulate_tween: Tween = null
var _move_tween: Tween = null
var _mood_tween: Tween = null
var _target_height: float = 0.0

func setup(
	p_character: CharacterDefinition,
	p_side: String,
	p_flip: bool,
	p_position_ratio: float,
	p_z_index: int,
	p_mood: String,
	initial_modulate: Color
) -> void:
	character = p_character
	side = p_side
	flip_h = p_flip
	position_ratio = p_position_ratio
	z_index = p_z_index
	texture = p_character.get_mood_texture(p_mood)
	modulate = initial_modulate
	# Center the texture around its anchor point.
	pivot_offset = size / 2.0
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE

## Set the height this display should occupy. Width is derived from the
## current texture's aspect ratio. Safe to call repeatedly — it'll no-op
## if nothing meaningful has changed.
func fit_to_height(target_height: float) -> void:
	_target_height = target_height
	_refit()

func _refit() -> void:
	if _target_height <= 0.0 or texture == null:
		return
	var tex_size := texture.get_size()
	if tex_size.y == 0.0:
		return
	var aspect := tex_size.x / tex_size.y
	size = Vector2(_target_height * aspect, _target_height)
	pivot_offset = size / 2.0


func tween_modulate(target: Color, duration: float) -> void:
	if _modulate_tween and _modulate_tween.is_valid():
		_modulate_tween.kill()
	if duration <= 0.0:
		modulate = target
		return
	_modulate_tween = create_tween()
	_modulate_tween.tween_property(self, "modulate", target, duration)


func tween_to_position(target_position: Vector2, target_z: int, duration: float) -> void:
	if _move_tween and _move_tween.is_valid():
		_move_tween.kill()
	z_index = target_z
	if duration <= 0.0:
		position = target_position
		return
	_move_tween = create_tween()
	_move_tween.tween_property(self, "position", target_position, duration)


func tween_to_mood(mood: String, duration: float) -> void:
	if _mood_tween and _mood_tween.is_valid():
		_mood_tween.kill()
	var new_texture := character.get_mood_texture(mood)
	if new_texture == null:
		return
	if duration <= 0.0:
		texture = new_texture
		_refit()
		return
	var original_modulate := modulate
	_mood_tween = create_tween()
	_mood_tween.tween_property(self, "modulate:a", 0.0, duration * 0.5)
	_mood_tween.tween_callback(func():
		texture = new_texture
		_refit()
	)
	_mood_tween.tween_property(self, "modulate:a", original_modulate.a, duration * 0.5)
