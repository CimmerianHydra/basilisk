extends Resource
class_name Check

var acc := 0
var flt := 0

## Result of the d20 roll.
var d20 := 0
## Result of the d6 rolls (accuracy/difficulty).
var d6_array := []

var rolled := false

func _init(accuracy : int, flat : int) -> void:
	acc = accuracy
	flt = flat

func describe() -> String:
	var to_return = "d20"
	if acc > 0:
		to_return += " + %sd6" % absi(acc)
	elif acc < 0:
		to_return += " - %sd6" % absi(acc)
	if flt > 0: to_return += " + %s" % flt
	
	if rolled:
		to_return += " = %s" % total
		to_return += " [%s" % d20
		for i in range(absi(acc)):
			if signi(acc) > 0: to_return += " +"
			if signi(acc) < 0: to_return += " -"
			to_return += " %s" % d6_array[i]
		if flt > 0: to_return += " %s" % flt
		to_return += "]"
	
	return to_return

func roll():
	d20 = randi_range(1, 20)
	d6_array = range(absi(acc)).map(func(_x): return randi_range(1, 6))
	rolled = true

func total() -> int:
	assert(rolled, "total() may only be called after roll()!")
	var tot = d20
	for d6 in d6_array:
		tot += signi(acc) * d6
	tot += flt
	return tot

func add_accuracy(): acc += 1
func add_difficulty(): acc -= 1
