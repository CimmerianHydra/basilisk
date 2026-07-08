extends BattleEvent
class_name WeaponHitEvent

enum Type {
	MISS,
	HIT,
	CRIT
}

## INITIAL DATA
var _attacker : Unit
var _defender : Unit
var _weapon : WeaponDefinition
var _total : int
var _against : int
var _crit : int

## FINAL DATA
var attacker : Unit
var defender : Unit
var weapon : WeaponDefinition
var total : int
var against : int
var crit : int

# EXTRA DATA
var lock_on_consumed : bool = false

func _init(atker : Unit, defer : Unit) -> void:
	setup(atker, defer)

func setup(atker : Unit, defer : Unit) -> void:
	_attacker = atker
	_defender = defer
	attacker = atker
	defender = defer

func resolve() -> void:
	var dmg_rolls = range(weapon.damage_dice).map(func(_i): return BattleEngine.world.d(weapon.damage_die_sides))
	
