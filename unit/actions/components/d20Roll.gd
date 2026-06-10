extends ActionComponent
class_name d20Roll

const D6_SIDES = 6
const D20_SIDES = 20

@export var play_animation: bool = false
@export var accuracy: int = 0
@export var modifier: int = 0

func execute(ctx: Dictionary) -> void:
	var d20_result := randi_range(1, D20_SIDES)
	var d6_results : Array[int] = []
	var total := d20_result
	for i in range(abs(accuracy)):
		var d6_result := randi_range(1, D6_SIDES)
		d6_results.append(d6_result)
		total = total + sign(accuracy) * d6_result
	
	# We should await the dice roll GUI here
	
	ctx[Action.D20_ROLL_KEY] = total
	if play_animation:
		var dice_roller : DiceRoller = get_tree().get_first_node_in_group(DiceRoller.GROUP)
		await dice_roller.roll(20, d20_result)
	trigger("d20_roll", ctx)
	print("Rolled %d" % [total])
	super(ctx)
