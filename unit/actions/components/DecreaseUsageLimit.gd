extends ActionComponent
class_name DecrementUsageLimit

@export var usage_limit : UsageLimit
@export var decrement := 1

func execute(ctx: Dictionary) -> void:
	usage_limit.per_turn -= decrement
	super(ctx)
