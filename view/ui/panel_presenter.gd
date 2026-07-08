class_name PanelPresenter
extends ChoicePresenter

## Presents any Choice as a titled list of buttons via the generic ChoicePanel.
## Owns the game-specific phrasing that used to live in HumanController.

var _panel: Control


func _init(panel: Control) -> void:
	_panel = panel


func present(choice: Choice) -> Variant:
	_panel.present(choice.prompt(), _labels_for(choice))
	var index: int = await _panel.selected
	return choice.get_options()[index]


func _labels_for(choice: Choice) -> Array[String]:
	if choice.get_options() == [true, false]:
		return ["Yes", "No"]

	var labels: Array[String] = []
	for option in choice.get_options():
		if option is Object and option.has_method("display_name"):
			labels.append(option.display_name())
		else:
			labels.append(str(option))
	return labels
