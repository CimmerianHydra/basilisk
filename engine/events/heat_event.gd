extends BattleEvent
class_name HeatEvent
## Heat landing on a unit — self-inflicted (HEAT_SELF, OVERKILL rerolls) or
## hostile (Heat X (Target), tech attacks). Heat is not damage: no ARMOR, its
## own pool. Kept separate so listeners can tell the two apart.

## INITIAL DATA
var _target: Unit
var _source: Unit
var _amount: int

## FINAL DATA
var target: Unit
var source: Unit
var amount: int


func _init(p_source: Unit, p_target: Unit, p_amount: int) -> void:
	setup(p_source, p_target, p_amount)


func setup(p_source: Unit, p_target: Unit, p_amount: int) -> void:
	_target = p_target
	_source = p_source
	_amount = p_amount
	target = p_target
	source = p_source
	amount = p_amount


func resolve() -> void:
	# TODO: Unit heat pool (heat_cap is already on FrameDefinition); overflow
	# past the cap is a stress/overheating check, a later milestone.
	target.increase_heat(amount)
	print("Unit %s took %s Heat from Unit %s." %
		[target.display_name(),
		amount,
		source.display_name()])
