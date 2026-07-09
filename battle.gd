extends Node3D

## Composition root for a PLAYABLE battle: builds the model (World), the views,
## and wires the human's presenter chain. Headless runs use headless_battle.tscn
## instead and never load this scene.

@onready var _grid_view: HexGridView = $GridView
@onready var _unit_layer: UnitLayer = $UnitLayer
@onready var _choice_panel: ChoicePanel = $GUI/ChoicePanel
@onready var _camera: RTSCamera = $RTSCamera
@onready var _radial_panel: RadialChoicePanel = $GUI/RadialPanel
@onready var _tile_layer: MoveHighlightLayer = $MoveHighlightLayer

var world := World.new()
var layout := HexLayout.new()


func _ready() -> void:
	BattleEngine.world = world
	world._grid = HexGrid.new().generate_circular(10, 1, 0.0, 1, 0)

	var list_presenter := PanelPresenter.new(_choice_panel)
	var radial_presenter := PanelPresenter.new(_radial_panel)
	var router := DecisionRouter.new(_unit_layer, _tile_layer, _camera, list_presenter, radial_presenter)
	var human := HumanController.new(router)
	
	var ai := RandomController.new(world)
	BattleEngine._controllers = [human, ai] as Array[Controller]

	_spawn_units(human, ai)

	_grid_view.build(world._grid, layout)
	_unit_layer.build(world, world._grid, layout)
	_tile_layer.build(world._grid, layout)

	BattleEngine.run_round()

# temporary
func _spawn_units(human: Controller, ai: Controller) -> void:
	var everest_frame: FrameDefinition = load("res://definitions/frames/player/gms_everest.tres")
	var assault_t1: FrameDefinition = load("res://definitions/frames/enemy/assault_T1.tres")
	var assault_rifle: WeaponDefinition = load("res://definitions/weapons/gms/assault_rifle.tres")
	var charged_blade: WeaponDefinition = load("res://definitions/weapons/gms/charged_blade.tres")

	var unit_a := Unit.new("Ally A", everest_frame)
	unit_a.set_controller(human)
	unit_a._faction = Unit.Faction.PLAYER
	unit_a.add_weapon(assault_rifle)
	unit_a.add_weapon(charged_blade)
	unit_a._position = Vector2i(-2, 1)

	var unit_b := Unit.new("Ally B", everest_frame)
	unit_b._faction = Unit.Faction.PLAYER
	unit_b.set_controller(human)
	unit_b.add_weapon(assault_rifle)
	unit_b._position = Vector2i(-2, 2)

	var enemy_a := Unit.new("Enemy A", assault_t1)
	enemy_a.set_controller(ai)
	enemy_a._faction = Unit.Faction.ENEMY
	enemy_a.add_weapon(assault_rifle)
	enemy_a._activations = 2
	enemy_a._position = Vector2i(2, 0)

	world.add_unit(unit_a)
	world.add_unit(unit_b)
	world.add_unit(enemy_a)
