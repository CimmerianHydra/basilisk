class_name HumanController
extends Controller

## Decision policy for the human player. Delegates the asking to a ChoicePresenter;
## knows nothing about nodes, panels, or 3D.

var _presenter: ChoicePresenter

func _init(presenter: ChoicePresenter) -> void:
	_presenter = presenter

func decide(choice: Choice) -> void:
	choice._answer = await _presenter.present(choice)

func display_name() -> String:
	return "Player"
