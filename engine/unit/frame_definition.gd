extends Resource
class_name FrameDefinition

enum MountType {
	MAIN,
	FLEX,
	HEAVY,
	SUPERHEAVY
}

@export var id : StringName = &"gms_everest"
@export var name : String = "Everest"
@export var brand : String = "GMS"

@export var size : int = 1
@export var armor : int = 0
@export var save_target : int = 10
@export var sensors : int = 10

@export var max_hp : int = 10
@export var repair_cap : int = 5

@export var evasion : int = 8
@export var speed : int = 4

@export var e_defense : int = 8
@export var tech_atk_bonus : int = 0
@export var system_points : int = 6

@export var heat_cap : int = 6

@export var mounts : Array[MountType] = [MountType.MAIN, MountType.FLEX, MountType.HEAVY]
