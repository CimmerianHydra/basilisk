extends BattleEvent
class_name DamageEvent

## INITIAL DATA
var _attacker : Unit
var _defender : Unit
var _damage : int

## FINAL DATA
var attacker : Unit
var defender : Unit
var damage : int

func _init(atker : Unit, defer : Unit, dmg : int) -> void:
	setup(atker, defer, dmg)

func setup(atker : Unit, defer : Unit, dmg : int) -> void:
	_attacker = atker
	_defender = defer
	_damage = dmg
	attacker = atker
	defender = defer
	damage = dmg

func resolve() -> void:
	defender.apply_damage(damage, Damage.Type.KINETIC)
