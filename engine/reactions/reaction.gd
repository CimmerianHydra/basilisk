extends RefCounted
class_name Reaction

## Reactions don't really expire, but a unit may lose them if a system is
## destroyed. They only have a maximum amount of uses.
var max_uses := 1
var _uses := 1 # Amount of remaining uses for this reaction.


@warning_ignore("redundant_await")
func on_event(event : BattleEvent) -> void: await _on_event(event)
func _on_event(_event : BattleEvent) -> void: return

@warning_ignore("redundant_await")
func after_event(event : BattleEvent) -> void: await _after_event(event)
func _after_event(_event : BattleEvent) -> void: return

func refresh_uses() -> void: _uses = max_uses
func expend_use() -> void: _uses -= 1

## Typically, reactions are usable once per round only. This usage needs to be
## explicitly coded into the reaction.
