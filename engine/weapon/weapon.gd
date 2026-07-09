class_name Weapon
extends RefCounted
## Runtime state of one weapon in one unit's hands.
##
## The definition stays immutable and shared; everything that changes during
## play — LOADING state, LIMITED charges, fired-this-action — lives here. This
## is also the object a projected timeline forks, which the definition, by
## design, never is.
## Intended path: res://engine/unit/equipped_weapon.gd
 
var definition: WeaponDefinition
 
## LOADING weapons flip to false after firing; STABILIZE (and some systems)
## reload them.
var loaded: bool = true
 
## LIMITED remaining uses. -1 means "not a limited weapon".
var charges: int = -1
 
## Set when the weapon fires, cleared when the action ends. Feeds the "may also
## attack with an AUXILIARY weapon on the same mount that hasn't fired yet" rule
## for SKIRMISH and BARRAGE.
var fired_this_action: bool = false
 
 
func _init(p_definition: WeaponDefinition) -> void:
	definition = p_definition
	# LIMITED is authored per-profile, but a weapon's modes share one ammo pool:
	# read it off the first profile that declares it.
	for profile: WeaponProfile in definition.profiles:
		if profile.has_tag(WeaponProfile.WeaponTag.LIMITED):
			charges = profile.tag_value(WeaponProfile.WeaponTag.LIMITED)
			break
 
 
## Can this weapon be offered in the SKIRMISH weapon pick at all?
## SUPERHEAVY weapons can only be fired as part of a BARRAGE.
func usable_in_skirmish(unit: Unit) -> bool:
	if definition.size == WeaponDefinition.Size.SUPERHEAVY:
		return false
	return _usable(unit)
 
 
func usable_in_barrage(unit: Unit) -> bool:
	return _usable(unit)
 
 
## Weapon-level gates: ammunition state. Profile-level gates (ORDNANCE) are
## checked per-profile in usable_profiles(), since one mode may be legal while
## another isn't.
func _usable(unit: Unit) -> bool:
	if not loaded:
		return false
	if charges == 0:
		return false
	return not usable_profiles(unit).is_empty()
 
 
## The firing modes this unit could legally declare right now.
func usable_profiles(unit: Unit) -> Array[WeaponProfile]:
	var result: Array[WeaponProfile] = []
	for profile: WeaponProfile in definition.profiles:
		if profile.has_tag(WeaponProfile.WeaponTag.ORDNANCE) and not _ordnance_legal(unit):
			continue
		result.append(profile)
	return result
 
 
## ORDNANCE: only before the unit has moved or taken any non-PROTOCOL action
## this turn. Needs a turn flag on Unit, set by BattleEngine whenever a move or
## action event resolves for it.
## TODO: wire up once per-turn state tracking lands. Permissive until then.
func _ordnance_legal(_unit: Unit) -> bool:
	return true
 
 
## Costs that firing always pays, hit or miss. HEAT_SELF joins this in
## milestone 2 (it needs the heat pipeline).
func consume_shot(profile: WeaponProfile) -> void:
	fired_this_action = true
	if profile.has_tag(WeaponProfile.WeaponTag.LOADING):
		loaded = false
	if charges > 0:
		charges -= 1
 
 
## STABILIZE's "reload all LOADING weapons" option, External Ammo Feed, etc.
func reload() -> void:
	loaded = true
 
 
## Call when the owning action finishes, so the aux follow-up bookkeeping
## doesn't leak into the next SKIRMISH/BARRAGE.
func reset_action_flags() -> void:
	fired_this_action = false
 
 
## Shown in the radial weapon pick; surfaces unusable-soon state at a glance.
func display_name() -> String:
	var text := definition.name
	if not loaded:
		text += " (unloaded)"
	elif charges >= 0:
		text += " (%d)" % charges
	return text
