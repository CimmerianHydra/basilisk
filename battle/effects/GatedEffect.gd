extends Effect
class_name GatedEffect

@export var on_success : Effect
@export var on_failure : Effect
@export var gate : Gate

func setup(success : Effect, failure : Effect, gating : Gate) -> GatedEffect:
	on_success = success
	on_failure = failure
	gate = gating
	return self

func sources(_world) -> void:
	if on_success: on_success.source = self.source
	if on_failure: on_failure.source = self.source

func targets(_world) -> void:
	if on_success: on_success.target = self.target
	if on_failure: on_failure.target = self.target

func resolve(world) -> void:
	if gate.success(): if on_success: 	on_success.resolve(world)
	else: if on_failure: 				on_failure.resolve(world)
