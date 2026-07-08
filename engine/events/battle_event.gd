extends RefCounted
class_name BattleEvent

var _initial_data # The data that this event is being broadcasted with
var _final_data # The data that this event contains after it has been influenced by modifiers
var _responders # The objects that responded to this event

## "How does this event modify the final data?"
func resolve() -> void: return
