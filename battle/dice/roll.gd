extends Resource
class_name Roll

## The amount of sides of the dice (typically 3, 6, 8 or 12).
@export var sid := 6
## The amount of rolls of identical dice to be summed together.
@export var amt := 1
## Flat modifier.
@export var flt := 0

var result_array := []
var rolled := false

func _init(sides : int = 6, amount : int = 1, flat : int = 0) -> void:
	sid = sides
	amt = amount
	flt = flat

func describe() -> String:
	var to_return = "%sd%s" % [amt, sid]
	if flt > 0: to_return += " + %s" % flt
	if rolled: to_return += " = %s" % total()
	return to_return

func roll(is_crit : bool = false):
	var amount = amt
	if is_crit: amount *= 2
	for i in range(amount):
		var r = randi_range(1, sid)
		result_array.append(r)
	rolled = true

func total() -> int:
	assert(rolled, "total() may only be called after roll()!")
	var tot = 0
	var tot_array = result_array.duplicate()
	tot_array.sort()
	tot_array.reverse()
	tot_array.resize(amt)
	for r in result_array:
		tot += r
	tot += flt
	return tot
