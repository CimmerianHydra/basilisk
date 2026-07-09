extends BattleEvent
class_name AttackRollEvent

## INITIAL DATA
var _attacker : Unit
var _defender : Unit
var _weapon : WeaponDefinition
var _roll_bonus : int = 0
var _accuracy : int = 0
var _difficulty : int = 0
var _ignores_cover : bool = false

## FINAL DATA
var attacker : Unit
var defender : Unit
var weapon : WeaponDefinition
var roll_bonus : int
var accuracy : int
var difficulty : int
var d6_rolls : Array = []
var d20_rolls : Array = []
var total : int = 0

# EXTRA DATA
var lock_on_consumed : bool = false

func _init(atker : Unit, defer : Unit) -> void:
	setup(atker, defer)

func setup(atker : Unit, defer : Unit) -> void:
	_attacker = atker
	_defender = defer
	attacker = atker
	defender = defer
	roll_bonus = _roll_bonus
	accuracy = _accuracy
	difficulty = _difficulty

func resolve() -> void:
	var ad_net = accuracy - difficulty
	var ad_sgn : int = signi(ad_net)
	var ad_amt : int = abs(ad_net)
	d6_rolls = range(ad_amt).map(func(_i): return BattleEngine.world.d(6))
	d20_rolls = [BattleEngine.world.d(20)]
	total += roll_bonus
	if not d6_rolls.is_empty(): total += d6_rolls.max() * ad_sgn
	if not d20_rolls.is_empty(): total += d20_rolls.max()
