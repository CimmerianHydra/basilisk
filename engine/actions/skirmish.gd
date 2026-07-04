extends BattleAction
class_name Skirmish

# NOTE: it seems like the structure of all these actions is always "write something in the context",
# then "await a phase", then "get something from the context".
# Or, equivalently, "get", then "write", then "await".

func execute() -> void:
	print("Unit %s skirmishes!" % [_unit.display_name()])
	
	set_ctx("actor", _unit)
	set_ctx("action_cost", 1)
	await phase("quick_action")
	_unit._quick_actions -= get_ctx("action_cost")
	
	set_ctx("attacker", _unit)
	var weapon : WeaponDefinition = await BattleEngine.ask(_unit._controller, _unit._weapons, "Choose weapon for Skirmish:")
	set_ctx("weapon", weapon)
	var target : Unit = await BattleEngine.ask(_unit._controller, BattleEngine.world.get_units(), "Choose target:")
	set_ctx("target", target)
	
	set_ctx("roll_bonus", 0)
	set_ctx("accuracy", 0)
	set_ctx("difficulty", 0)
	await phase("attack_roll_prep")
	
	var ad_net = get_ctx("accuracy") - get_ctx("difficulty")
	var ad_sgn : int = signi(ad_net)
	var ad_amt : int = abs(ad_net)
	var ad_rolls : Array = range(ad_amt).map(func(): return BattleEngine.world.d(6))
	var base_roll : int = BattleEngine.world.d(20)
	set_ctx("ad_sgn", ad_sgn)
	if not ad_rolls.is_empty():
		set_ctx("ad_rolls", ad_rolls)
	set_ctx("base_roll", base_roll)
	set_ctx("check_against", target.get_evasion())
	await phase("attack_roll_eval")
	
	var total = get_ctx("base_roll") + get_ctx("roll_bonus") + get_ctx("ad_sgn") * get_ctx("ad_rolls", [0]).max()
	
	if total > get_ctx("check_against"):
		await phase("attack_hit")
		
		if total > 20:
			await phase("attack_crit")
		
		await phase("damage_roll_prep")
		await phase("damage_roll_eval")
		
		target.apply_damage(weapon.damage_die_sides, weapon.damage_type)
	else:
		await phase("attack_miss")
	print(_ctx)

func display_name() -> String: return "Skirmish"
