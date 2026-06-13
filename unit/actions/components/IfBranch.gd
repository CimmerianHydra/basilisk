extends ActionComponent
class_name IfBranch

@export var condition : ActionCondition

func execute(ctx: Dictionary) -> void:
	if condition.check(ctx):
		await execute_children(ctx)
