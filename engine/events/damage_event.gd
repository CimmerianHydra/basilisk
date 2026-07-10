extends BattleEvent
class_name DamageEvent
## One quantum of damage landing on one unit. ALL damage application goes
## through here — this is where ARMOR (unless AP) lives, and where RESISTANCE,
## EXPOSED, and SHREDDED will live. Views animate off event_resolved.

## INITIAL DATA
var _target: Unit
var _amount: int
var _type: Damage.Type
var _ap: bool
var _source: Unit

## FINAL DATA
var target: Unit
var amount: int
var type: Damage.Type
var ap: bool
var source: Unit

## EXTRA DATA
# Post-armor damage actually applied; for logs and vampiric-style listeners.
var dealt: int = 0


func _init(p_source: Unit, p_target: Unit, p_amount: int, p_type: Damage.Type, p_ap: bool) -> void:
	setup(p_source, p_target, p_amount, p_type, p_ap)


func setup(p_source: Unit, p_target: Unit, p_amount: int, p_type: Damage.Type, p_ap: bool) -> void:
	_target = p_target
	_amount = p_amount
	_type = p_type
	_ap = p_ap
	_source = p_source
	target = p_target
	amount = p_amount
	type = p_type
	ap = p_ap
	source = p_source


func resolve() -> void:
	var reduced := amount
	# ARMOR reduces kinetic/energy/explosive; BURN ignores it by rule, and HEAT
	# should travel as a HeatEvent rather than through here.
	if not ap and type != Damage.Type.BURN:
		reduced = maxi(amount - target.get_armor(), 0)
	# TODO: RESISTANCE (half), EXPOSED (double), SHREDDED (no armor/resistance)
	# once conditions exist — all in this one place.
	dealt = reduced
	target.decrease_hp(dealt)
	print("Unit %s took %s %s damage from Unit %s." %
		[target.display_name(),
		dealt, Damage.display_name(type),
		source.display_name()])
