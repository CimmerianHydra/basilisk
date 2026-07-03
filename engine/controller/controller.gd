extends RefCounted
class_name Controller

## Modifies the "choice" to have a result.
func decide(choice : Choice) -> void: await choice
func display_name() -> String: return "Controller"
