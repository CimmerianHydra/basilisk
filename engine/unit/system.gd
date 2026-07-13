class_name System
extends RefCounted
## Runtime state of one system installed in a unit.
##
## The definition stays immutable and shared; everything that changes during
## play — charges, fired-this-action — lives here. This
## is also the object a projected timeline forks, which the definition, by
## design, never is.

var definition: SystemDefinition

## LIMITED remaining uses. -1 means "not a limited system".
var charges: int = -1

func _init(p_definition: SystemDefinition) -> void:
	definition = p_definition
	# If the system is limited, initialize its charges at creation. Otherwise, -1.
	if definition.has_tag(SystemDefinition.SystemTag.LIMITED):
		charges = definition.tag_value(SystemDefinition.SystemTag.LIMITED)

func expend() -> void:
	if definition.has_tag(SystemDefinition.SystemTag.LIMITED):
		if charges > 0: charges -= 1

## Shown in the radial weapon pick; surfaces unusable-soon state at a glance.
func display_name() -> String:
	var text := definition.name
	if charges >= 0:
		text += " (%d)" % charges
	return text
