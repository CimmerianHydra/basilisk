extends Node3D

@export var map_width: int = 12
@export var max_tile_height: int = 0

@onready var hex_grid_3d = $HexGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var layout := HexLayout.new()
	layout.size = 1.0
	layout.height_step = 2.0

	var grid := HexGrid.generate_circular(
		map_width,
		max_tile_height,
		layout,
		)
	hex_grid_3d.grid = grid

# for testing
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$EventBus.trigger("player_turn_start", {})
