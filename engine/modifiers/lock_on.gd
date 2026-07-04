extends Modifier
class_name LockOn

var _target : Unit

func _init(target : Unit) -> void:
	_target = target
	_ticks = -1

func apply(ctx : Dictionary):
	if not ctx["window"] == "attack_roll_prep": return
	if not ctx["target"] == _target: return
	var consumed = await BattleEngine.ask(ctx["attacker"]._controller, [true, false], "Consume Lock On?")
	ctx["lock_on_consumed"] = consumed
	tick_zero()
