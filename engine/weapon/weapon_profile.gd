class_name WeaponProfile
extends Resource
## One way of firing a weapon. Most weapons have exactly one; a few (the Siege
## Cannon's Siege vs Direct Fire) choose between several at declare time, which
## is why reach, pattern, damage, and tags all live HERE and not on the
## definition.
##
## Like WeaponDefinition, this is authored data: created as a sub-resource in
## the inspector, shared, never mutated at runtime.
## Intended path: res://engine/unit/weapon_profile.gd
 
## How the attack roll is made. Melee uses THREAT for reach and ignores cover;
## ranged uses RANGE and respects cover. (CQB/Rifle/etc. are all RANGED.)
enum AttackKind {
	MELEE,
	RANGED,
}
 
## Shape of the affected area. NONE = attack a single picked unit.
## BLAST anchors on a picked point within RANGE + LoS (cover/LoS for the
## per-target rolls are then measured from that point). BURST surrounds the
## user (who is excluded unless a rule says otherwise). CONE and LINE project
## from the user in a picked direction.
enum Pattern {
	NONE,
	BLAST,
	BURST,
	CONE,
	LINE,
}
 
## Derived from tags — see los_policy(). STANDARD needs line of sight.
## ARCING needs none (cover still applies at roll time). SEEKING ignores both
## LoS and cover, needing only a physically possible path.
enum LosPolicy {
	STANDARD,
	ARCING,
	SEEKING,
}
 
## Book tags (p. 104-105). Boolean tags store 1 in `tags`; valued tags store X.
enum WeaponTag {
	AP,         ## Damage ignores ARMOR.
	ACCURATE,   ## +1 Accuracy on attacks.
	INACCURATE, ## +1 Difficulty on attacks.
	RELIABLE,   ## Always deals at least X damage, even on a miss.
	OVERKILL,   ## Damage dice landing on 1 deal 1 heat to the attacker and reroll.
	KNOCKBACK,  ## On hit, may push the target X spaces away from the point of origin.
	LOADING,    ## Must be reloaded after each use.
	SMART,      ## Attacks target E-DEFENSE instead of EVASION (8 if the target has none).
	ORDNANCE,   ## Only before moving/other actions; can't hit engaged targets; no Overwatch.
	ARCING,     ## No line of sight needed, still affected by cover.
	SEEKING,    ## Ignores cover and line of sight if a path exists.
	LIMITED,    ## X total uses.
	HEAT_SELF,  ## The user takes X heat when the weapon is fired, hit or miss.
	THROWN,     ## Melee weapon usable at X spaces (affected by cover; must be retrieved).
}
 
## Empty for single-profile weapons; "Siege" / "Direct Fire" style otherwise.
@export var profile_name: String = ""
@export var attack_kind: AttackKind = AttackKind.RANGED
 
## Reach in spaces. `max_range` for RANGED attacks (and the anchor distance of
## a BLAST); `threat` for MELEE reach and OVERWATCH. `min_range` for weapons
## like the Apocalypse Rail that can't fire close (0 = no minimum).
@export var max_range: int = 0
@export var threat: int = 1
@export var min_range: int = 0
 
@export var pattern: Pattern = Pattern.NONE
@export var pattern_size: int = 0
 
@export var damage_packets: Array[DamagePacket] = []
 
## WeaponTag -> value. Kept as open data so the .tres mirrors the book's stat
## line; behavior is derived from it at attack time.
@export var tags: Dictionary[WeaponTag, int] = {}
 
# Milestone 2: unique riders ("On Hit: HULL save or IMPAIRED") become resources.
#@export var effects: Array[WeaponEffect] = []
 
 
func has_tag(tag: WeaponTag) -> bool:
	return tags.has(tag)
 
 
## The value (X) of a tag, or 0 if the profile lacks it.
func tag_value(tag: WeaponTag) -> int:
	return tags.get(tag, 0)
 
 
func is_melee() -> bool:
	return attack_kind == AttackKind.MELEE
 
 
## Reach used when building the candidate list.
func reach() -> int:
	return threat if is_melee() else max_range
 
 
## Tags are the single source of truth; policies are derived, never re-entered.
func los_policy() -> LosPolicy:
	if has_tag(WeaponTag.SEEKING):
		return LosPolicy.SEEKING
	if has_tag(WeaponTag.ARCING):
		return LosPolicy.ARCING
	return LosPolicy.STANDARD
 
 
## SMART attacks must be jammed, not dodged: they hit E-DEFENSE.
func targets_e_defense() -> bool:
	return has_tag(WeaponTag.SMART)
 
 
## Cover applies only to ranged, non-SEEKING attacks (checked at roll time).
func ignores_cover() -> bool:
	return is_melee() or has_tag(WeaponTag.SEEKING)
 
 
func display_name() -> String:
	return profile_name
