class_name Damage

## The kind of damage dealt. Likely promoted to a shared location once the damage
## Op and resistances need to reference it too.
enum Type { KINETIC, ENERGY, EXPLOSIVE, BURN, HEAT }

static func display_name(type : Type) -> String:
	match type:
		Type.KINETIC: return "Kinetic"
		Type.ENERGY: return "Energy"
		Type.EXPLOSIVE: return "Explosive"
		Type.BURN: return "Burn"
		Type.HEAT: return "Heat"
		_: return "???"
