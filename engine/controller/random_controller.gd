extends Controller
class_name RandomController

## Takes decisions randomly.
var _world : World

func _init(world : World) -> void:
	_world = world

func decide(choice : Choice) -> void:
	var amount_of_choices = len(choice._options)
	var random_choice = _world.d(amount_of_choices)
	choice._answer = choice._options[random_choice - 1]

func display_name() -> String: return "Random AI"
