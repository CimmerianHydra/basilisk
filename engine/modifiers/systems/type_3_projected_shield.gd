extends Modifier
class_name Type3ProjectedShieldMod

## "Nominate a character within line of sight: all
## ranged or melee attacks that they make against
## you or that you make against them gain +2 DIFF
## until the start of your next turn"

var _target : Unit
var _chosen : Unit

func _init(target : Unit, chosen : Unit) -> void:
	_target = target
	_chosen = chosen
	_ticks = 1

func _on_event(event : BattleEvent) -> void:
	if event is AttackRollEvent:
		if (event.defender == _target and event.attacker == _chosen) or \
		   (event.defender == _chosen and event.attacker == _target):
			event.difficulty += 2
	if event is TurnStartEvent:
		if not event.actor == _target: return
		tick_down()
