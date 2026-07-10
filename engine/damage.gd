class_name Damage

## The kind of damage dealt. Likely promoted to a shared location once the damage
## Op and resistances need to reference it too.
## Heat is not a type of damage, though it may be converted to one according to
## specific Traits (Biological units).
enum Type { KINETIC, ENERGY, EXPLOSIVE, BURN }

static func display_name(type : Type) -> String:
	match type:
		Type.KINETIC: return "Kinetic"
		Type.ENERGY: return "Energy"
		Type.EXPLOSIVE: return "Explosive"
		Type.BURN: return "Burn"
		_: return "???"
