extends Node3D

var world = World.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BattleEngine.world = world
	
	var human_controller = HumanController.new($GUI/ChoicePanel)
	BattleEngine._controllers.append(human_controller)
	
	var random_controller = RandomController.new(world)
	BattleEngine._controllers.append(random_controller)
	
	var everest_frame : FrameDefinition = load("res://definitions/frames/gms_everest.tres")
	var assault_rifle : WeaponDefinition = load("res://definitions/weapons/gms/assault_rifle.tres")
	var charged_blade : WeaponDefinition = load("res://definitions/weapons/gms/charged_blade.tres")
	
	var unit_a = Unit.new("Ally A", everest_frame)
	unit_a.set_controller(human_controller)
	unit_a._weapons.append(assault_rifle)
	unit_a._weapons.append(charged_blade)
	
	var unit_b = Unit.new("Ally B", everest_frame)
	unit_b.set_controller(human_controller)
	unit_b._weapons.append(assault_rifle)
	
	var enemy_a = Unit.new("Enemy A", everest_frame)
	enemy_a.set_controller(random_controller)
	enemy_a._faction = Unit.Faction.ENEMY
	enemy_a._weapons.append(assault_rifle)
	enemy_a._activations = 2
	
	world.add_unit(unit_a)
	world.add_unit(unit_b)
	world.add_unit(enemy_a)
	
	BattleEngine.run_round()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
