extends BattleEvent
class_name WeaponAttackEvent

## Takes the information from a given AttackRollEvent and uses it to build a
## pipeline that answers the question: "an attack roll was made. Now apply all
## the effects that a weapon would have, given its outcome."

enum Outcome { MISS, HIT, CRIT }

## INITIAL DATA
var _against: int
var _damage_rolls = []
var _profile: WeaponProfile
var _crit_on : int = 20

## FINAL DATA
var attacker: Unit
var defender: Unit
var crit_on : int = _crit_on
var damage_rolls = []
var profile: WeaponProfile
var total: int        ## The attack roll's final result.
var against: int      ## The defense it must match or beat (EVASION or E-DEFENSE).


func _init(p_roll : AttackRollEvent, p_against: int, p_profile: WeaponProfile) -> void:
	setup(p_roll, p_against, p_profile)


func setup(p_roll : AttackRollEvent, p_against: int, p_profile: WeaponProfile) -> void:
	_profile = p_profile
	_against = p_against
	attacker = p_roll.attacker
	defender = p_roll.defender
	profile = p_profile
	total = p_roll.total
	against = p_against


## Derived, not stored: always reflects the current (possibly modified) numbers
## at the moment it is asked. The view layer can call this on event_resolved.
func outcome() -> Outcome:
	if total < against:
		return Outcome.MISS
	return Outcome.CRIT if total >= crit_on else Outcome.HIT

func validate() -> bool:
	# Check if damage was rolled
	if _damage_rolls.is_empty(): return false
	return true

func resolve() -> void:
	var has_ap := profile.has_tag(WeaponProfile.WeaponTag.AP)
	var reliable := profile.tag_value(WeaponProfile.WeaponTag.RELIABLE)

	match outcome():
		Outcome.MISS:
			print("  Miss vs %s." % defender.display_name())
			# RELIABLE X "always deals at least X damage, even on a miss" — it
			# inherits AP and the base damage type, but no on-hit riders.
			if reliable > 0 and not damage_rolls.is_empty():
				var base: DamagePacket = damage_rolls[0].packet
				await _deal(reliable, base.type, has_ap)

		Outcome.HIT, Outcome.CRIT:
			var crit := outcome() == Outcome.CRIT
			print("  %s vs %s." % ["CRIT" if crit else "Hit", defender.display_name()])
			var key := "crit" if crit else "normal"

			var amounts: Array[int] = []
			var sum := 0
			for entry: Dictionary in damage_rolls:
				amounts.append(entry[key])
				sum += entry[key]
			# RELIABLE floors the attack's TOTAL damage: top up once, rather
			# than applying it per packet.
			if reliable > sum and not amounts.is_empty():
				amounts[0] += reliable - sum

			for i in damage_rolls.size():
				var packet: DamagePacket = damage_rolls[i].packet
				await _deal(amounts[i], packet.type, has_ap)
			
			# TODO(bonus damage): bonus packets are halved on multi-target
			# attacks; base packets never are.
			# TODO: on-hit riders (KNOCKBACK, Burn, save-or-status) run here as
			# WeaponEffects, on-crit extras after them.


## Damage re-enters the pipeline, so it gets its own staging pass: resistance
## and armor-style effects (a future Brace) hook DamageEvent, not this event.
func _deal(amount: int, type: Damage.Type, ap: bool) -> void:
	var dmg := DamageEvent.new(attacker, defender, amount, type, ap)
	await BattleEngine.stage_event(dmg)
	await BattleEngine.resolve_event(dmg)
