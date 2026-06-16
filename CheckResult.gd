extends RefCounted
class_name CheckResult

var d20 := 0
var d6_rolls: Array[int] = []
var d6_sign := 1
var flat_modifier := 0
var total := 0
var threshold := 0
var success := false
var is_crit := false
var is_fumble := false

## e.g. "d20(14) +2d6(4, 3) = 21 vs DC 15 — Success"
func describe() -> String:
	var text := "d20(%d)" % d20
	if not d6_rolls.is_empty():
		var faces := PackedStringArray()
		for d in d6_rolls:
			faces.append(str(d))
		var sign_text := "+" if d6_sign >= 0 else "-"
		text += " %s%dd6(%s)" % [sign_text, d6_rolls.size(), ", ".join(faces)]
	if flat_modifier != 0:
		text += " %+d" % flat_modifier
	return "%s = %d vs DC %d — %s" % [text, total, threshold, "Success" if success else "Failure"]
