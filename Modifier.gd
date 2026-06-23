extends Node
class_name Modifier

## Modifiers are similar to "new, local rules to the game" in a very general sense.
## They exist outside of units and outside of the board, even though they can model
## generic effects that apply to units.
##
## For example, Take Aim is modeled as a Modifier: when an Attack Roll is made with
## a ranged weapon by its "target", it adds an accuracy to the roll.
## While it is true that Take Aim in some ways "belongs" to the unit intuitively,
## this doesn't need to be the case from the point of view of the game engine. All
## the engine has to do is consult all modifiers and apply them as needed; the
## modifier doesn't need to be stored on the unit itself.

var source : Variant
var target : Variant

const GROUP := "modifiers"
func _init() -> void: add_to_group(GROUP)

func on_event(_event : Event): return
