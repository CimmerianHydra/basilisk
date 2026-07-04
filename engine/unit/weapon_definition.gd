class_name WeaponDefinition
extends Resource
## Static, authored profile of a weapon.
##
## This is a definition, not runtime state: it is created in the inspector as a
## .tres, shared by every mech that equips it, and never mutated at runtime.
## Mutating a WeaponDefinition would change it for every mech — and every
## projected timeline — at once.

## How the weapon's attack roll is made and which defense it targets.
enum AttackKind {
	MELEE,   ## Uses THREAT for reach, ignores cover, targets EVASION.
	RANGED,  ## Uses RANGE, affected by cover, targets EVASION.
}

enum WeaponTag {
	AP, ## Armour-Piercing: damage ignores ARMOR.
	ACCURATE, ## +1 Accuracy on attacks.
	INACCURATE, ## +1 Difficulty on attacks.
	RELIABLE, ## Deals at least X damage, even on a miss.
	OVERKILL,  ## Damage dice showing 1 deal heat and reroll.
	KNOCKBACK, ## On hit, knock the target X spaces.
	LOADING, ## Must be reloaded after firing.
	SMART ## Uses EDefense instead of Evasion to determine hit.
}

@export var id: StringName = &""
@export var name: String = ""
@export var attack_kind: AttackKind = AttackKind.RANGED

## Reach in spaces. `max_range` is used for RANGED attacks; `threat` for MELEE
## reach and for OVERWATCH with either kind. Threat defaults to 1.
@export var max_range: int = 0
@export var threat: int = 1

@export var attack_bonus: int = 0
@export var damage_type: Damage.Type = Damage.Type.KINETIC
## Damage as <damage_dice>d<damage_die_sides> + <damage_flat>.
## e.g. 1d6+2 -> dice 1, sides 6, flat 2.  A flat 3 -> dice 0, sides 0, flat 3.
@export var damage_dice: int = 0
@export var damage_die_sides: int = 0
@export var damage_flat: int = 0

## WeaponTag -> value. Boolean tags store 1; valued tags store their X
## (e.g. {&"reliable": 3}). Keeping tags as open data means a new tag is content,
## not an engine change.
@export var tags: Dictionary[WeaponTag, int] = {}

## Returns true if the weapon carries the given tag.
func has_tag(tag: WeaponTag) -> bool:
	return tags.has(tag)

## Returns the value (X) of a tag, or 0 if the weapon lacks it.
func tag_value(tag: WeaponTag) -> int:
	return tags.get(tag, 0)

func display_name() -> String: return name
