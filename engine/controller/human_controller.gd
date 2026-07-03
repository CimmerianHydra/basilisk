class_name HumanController
extends Controller

## Asynchronous decision policy for the human player. Formats a ChoiceRequest into
## readable labels, hands them to a generic ChoicePanel, and awaits the click. The
## panel returns a chosen index; this maps it back to the real option value. All the
## game-specific phrasing lives here, keeping the panel reusable.

var _panel: ChoicePanel


func _init(panel: ChoicePanel) -> void:
	_panel = panel


func decide(choice: Choice) -> void:
	_panel.present(_title_for(choice), _labels_for(choice))
	var index: int = await _panel.selected
	choice._answer = choice._options[index]


func _title_for(choice: Choice) -> String:
	return choice._ctx["prompt"]


func _labels_for(choice: Choice) -> Array[String]:
	if choice._options == [true, false]: return ["Yes", "No"]
	
	var labels: Array[String] = []
	for option in choice._options:
		labels.append(option.display_name())
	
	return labels

func display_name() -> String: return "Player"
