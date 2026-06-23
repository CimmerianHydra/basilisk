extends Node
class_name ActionResolver

func _init() -> void:
	var damage_effect = DamageEffect.new()
	damage_effect.amount = 5
	var gate = CheckGate.new().setup(Check.new(0, 0), 0)
	var gated_damage = GatedEffect.new().setup(damage_effect, Effect.NONE, gate)
	gated_damage.target = "Testing Target"
	gated_damage.source = "Testing Source"
	
	var test_action = Action.new()
	test_action.name = "Test"
	test_action.type = Action.Type.FREE
	
	test_action.effect = gated_damage
	
	resolve(test_action, null)

func resolve(action : Action, world : World):
	var a = action.duplicate()
	# Step 1: set source
	# Step 2: pay cost
	# Step 3: set target
	# a.targeting.apply_targets(a.effect)
	# Step 4: resolve the effect
	EffectResolver.resolve(a.effect, world)
