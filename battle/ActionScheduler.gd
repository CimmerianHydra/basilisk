extends Node
class_name ActionScheduler

func _ready() -> void:
	run_children()

func run_children() -> void:
	for child in get_children():
		if child is Action:
			run(child)

func run(sequence: Action) -> void:
	if not _accept(sequence):
		return
	await _run(sequence)


#--------- Internal Functions ----------#

func _accept(sequence: Action) -> bool:
	if sequence == null or not is_instance_valid(sequence):
		push_error("ActionScheduler: rejected null or invalid action.")
		return false
	return true

func _run(action: Action) -> void:
	await action.run()
