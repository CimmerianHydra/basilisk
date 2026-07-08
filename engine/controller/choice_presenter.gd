extends RefCounted
class_name ChoicePresenter

## Contract between a HumanController and whatever surface asks the human.
## Implementations decide HOW to ask (3D picking, button panel, console...) and
## must return one element of choice.get_options().


func present(choice: Choice) -> Variant:
	push_warning("ChoicePresenter.present() not overridden; picking first option.")
	@warning_ignore("redundant_await")
	await choice # No-op await: keeps this a coroutine so callers can always `await` it.
	return choice.get_options().front()
