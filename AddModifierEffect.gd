extends Effect
class_name AddModifierEffect

var mod : Modifier

func resolve(world : World) -> void:
	mod.source = source
	mod.target = target
	world.add_modifier(mod)
