class_name WeaponDefinition
extends Resource
## Static, authored identity of a weapon.
##
## This is a definition, not runtime state: it is created in the inspector as a
## .tres, shared by every mech that equips it, and never mutated at runtime.
## Mutating a WeaponDefinition would change it for every mech — and every
## projected timeline — at once. Per-unit mutable state (loaded, charges) lives
## in EquippedWeapon.
##
## Everything about HOW the weapon fires — reach, pattern, damage, tags — moved
## into WeaponProfile, because some weapons fire in more than one way and the
## modes disagree on all of it.
## Intended path: res://engine/unit/weapon_definition.gd
 
## Mount size. Only AUXILIARY (free follow-up attacks, no bonus damage) and
## SUPERHEAVY (BARRAGE-only, no Overwatch) carry special rules.
enum Size {
	AUXILIARY,
	MAIN,
	HEAVY,
	SUPERHEAVY,
}
 
@export var id: StringName = &""
@export var name: String = ""
@export var size: Size = Size.MAIN
 
## Firing modes. Almost always exactly one; the Siege Cannon has two, chosen
## when the attack is declared ("On Attack: choose siege or direct fire mode").
@export var profiles: Array[WeaponProfile] = []
 
 
func display_name() -> String:
	return name
