extends RefCounted
class_name Modifier

var _ticks := -1 # How many remaining ticks of duration the modifier has. Negative = infinite duration

func apply(_ctx : Dictionary) -> void: return
func tick_down(): _ticks -= 1
func tick_up(): _ticks += 1
func tick_zero(): _ticks = 0
