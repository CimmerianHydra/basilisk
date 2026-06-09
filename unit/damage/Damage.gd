extends Resource
class_name Dmg

enum Type {
	KINETIC,
	ENERGY,
	EXPLOSIVE,
	BURN,
}

@export var amount: int = 0
@export var type: Dmg.Type = Dmg.Type.KINETIC
