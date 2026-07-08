extends RefCounted
class_name Controller

## Modifies the "choice" to have a result.
@warning_ignore("redundant_await")
func decide(choice : Choice) -> void: await choice
func display_name() -> String: return "Controller"
