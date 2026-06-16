extends RefCounted
class_name Check

## One d20 check against one threshold: 1d20 + a signed count of d6 (positive adds
## dice, negative subtracts) + a flat modifier, compared against a target number.
## Pure: knows dice and probability, nothing about Units. Build with AttackCheckBuilder,
## then roll() it (execution) or ask success_chance() (preview / AI) — same numbers.

const D20_SIDES := 20
const D6_SIDES := 6

## Net signed count of accuracy d6. +2 = roll 2d6 and add; -1 = roll 1d6 and subtract.
var accuracy := 0
## Flat additive bonus to the total.
var flat_modifier := 0
## Number to meet or beat. For an attack, the target's evasion.
var threshold := 0
## Where the modifiers came from, for UI breakdowns.
var breakdown: Array[Dictionary] = []

func add_modifier(source: String, accuracy_delta: int, flat_delta := 0) -> void:
	accuracy += accuracy_delta
	flat_modifier += flat_delta
	breakdown.append({"source": source, "accuracy": accuracy_delta, "flat": flat_delta})

func roll() -> CheckResult:
	var d20 := randi_range(1, D20_SIDES)
	var s := signi(accuracy)
	var d6_rolls: Array[int] = []
	var total := d20 + flat_modifier
	for _i in absi(accuracy):
		var d6 := randi_range(1, D6_SIDES)
		d6_rolls.append(d6)
		total += s * d6

	var result := CheckResult.new()
	result.d20 = d20
	result.d6_rolls = d6_rolls
	result.d6_sign = s
	result.flat_modifier = flat_modifier
	result.total = total
	result.threshold = threshold
	result.success = total >= threshold      # "meets it beats it"
	result.is_crit = d20 == D20_SIDES
	result.is_fumble = d20 == 1
	return result

## Exact probability of success
func success_chance() -> float:
	var dist := _dice_distribution()
	var chance := 0.0
	for value in dist:
		if value + flat_modifier >= threshold:
			chance += dist[value]
	return chance

# --- probability helpers ---

## { total : probability } for (1d20 + signed d6 sum); flat modifier handled at compare time.
func _dice_distribution() -> Dictionary:
	var dist: Dictionary = {}
	for face in range(1, D20_SIDES + 1):
		dist[face] = 1.0 / D20_SIDES
	dist = _convolve_d6(dist, accuracy)
	return dist

func _convolve_d6(dist: Dictionary, amount: int) -> Dictionary:
	var out: Dictionary = {}
	for _i in absi(amount):
		for value in dist:
			var p: float = dist[value]
			for face in range(1, D6_SIDES + 1):
				var v = value + signi(amount) * face
				out[v] = out.get(v, 0.0) + p / D6_SIDES
	return out
