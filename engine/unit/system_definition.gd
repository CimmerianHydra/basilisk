class_name SystemDefinition
extends Resource
## Static, authored identity of a system. Also works for Traits.
##
## This is a definition, not runtime state: it is created in the inspector as a
## .tres, shared by every mech that equips it, and never mutated at runtime.
## Mutating a definition would change it for every mech — and every
## projected timeline — at once. Per-unit mutable state (charges) lives
## in System.
 
@export var id: StringName = &""
@export var name: String = ""
@export var SP_cost: int = 0
@export var tags: Dictionary[SystemTag, int] = {}
@export var can_be_destroyed: bool = true
@export var can_be_removed: bool = true

## Things that are granted to the unit "on install".

#@export var modifier_grants: Array[GDScript]
@export var action_grants: Array[GDScript]


## Boolean tags store 1 in `tags`; valued tags store X.
enum SystemTag {
	RECHARGE,   ## Throw a d6: if the result is X or more, the system can be used again.
	LIMITED,    ## X total uses.
}

func has_tag(tag: SystemTag) -> bool:
	return tags.has(tag)
 
## The value (X) of a tag, or 0 if the profile lacks it.
func tag_value(tag: SystemTag) -> int:
	return tags.get(tag, 0)
