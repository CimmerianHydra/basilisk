extends RefCounted
class_name BattleEvent

## BattleEvents are the only places that can modify the world directly.
## Nothing else is allowed to directly alter the data in the world, and any
## data-altering function from other classes (if they exist inside of the world,
## like Units) will eventually be called here and only here.
## This structure essentially defines what can happen to the world in the first
## place, which makes it the perfect place to call upon modifiers and reactions.

## The pipeline goes as follows: an event is first STAGED, which allows modifiers
## to alter its data and reactions to fire, then it is RESOLVED, which means
## first verifying whether the data is still correct (the target of any given
## VoluntaryMoveEvent could've died after staging and before resolution, due to
## an Overwatch killing it for example). If it's not validated, the event is
## canceled.

enum Result {
	RESOLVED,
	CANCELED
}

## "How does this event modify the final data?"
## TODO: cancellation pipeline
func resolve() -> void: return

## Every event needs to verify that the data it's trying to modify still exists
## before it attempts to access them.
func verify() -> bool: return true
