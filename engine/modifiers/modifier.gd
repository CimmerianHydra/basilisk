extends RefCounted
class_name Modifier

var _ticks := -1 # How many remaining ticks of duration the modifier has. Negative = infinite duration


@warning_ignore("redundant_await")
func apply(ctx : Dictionary) -> void: if _ticks > 0: await _apply(ctx)
func _apply(_ctx : Dictionary) -> void: return

@warning_ignore("redundant_await")
func on_event(event : BattleEvent) -> void: await _on_event(event)
func _on_event(_event : BattleEvent) -> void: return


func tick_down(): _ticks -= 1
func tick_up(): _ticks += 1
func tick_zero(): _ticks = 0
