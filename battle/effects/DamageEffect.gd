extends Effect
class_name DamageEffect

@export var amount : int

func resolve(_world) -> void:
	print("%s dealt %s damage to %s!" % [source, amount, target])
