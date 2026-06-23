extends Gate
class_name CheckGate

@export var check : Check
@export var threshold : int

func setup(dice_roll : Check, total_above : int) -> CheckGate:
	check = dice_roll
	threshold = total_above
	return self

func success() -> bool:
	check.roll()
	return check.total() > threshold
