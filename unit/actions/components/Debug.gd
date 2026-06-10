extends ActionComponent
class_name Debug

func execute(ctx: Dictionary) -> void:
	print("Debug Action component reached.")
	# Timer to test sync reactions
	await get_tree().create_timer(5.0).timeout
	print("Context: {0}".format([ctx]))
