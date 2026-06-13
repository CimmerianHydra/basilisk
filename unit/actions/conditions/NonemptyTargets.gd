extends ActionCondition
class_name NonemptyTargets

func check(ctx : Dictionary) -> bool:
	return ctx[Action.TARGETS_KEY].size() > 0
