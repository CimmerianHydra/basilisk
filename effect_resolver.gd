extends Node

func resolve(effect : Effect, world : World) -> void:
	effect.sources(world)
	effect.targets(world)
	effect.resolve(world)
