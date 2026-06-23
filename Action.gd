extends Resource
class_name Action

enum Type {
	FREE,
	PROTOCOL,
	QUICK,
	FULL,
	REACTION
}

@export_category("Generic Information")
@export var name : String
@export var type : Action.Type

@export_category("Mechanics")
var trigger
var cost

var sourcing
var targeting

@export var effect : Effect

var context : Dictionary = {}
