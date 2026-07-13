class_name WeaponProfile
extends Resource

## One way of firing a weapon. Most weapons have exactly one; a few (the Siege
## Cannon's Siege vs Direct Fire) choose between several at declare time, which
## is why reach, pattern, damage, and tags all live HERE and not on the
## definition.
##
## Like WeaponDefinition, this is authored data: created as a sub-resource in
## the inspector, shared, never mutated at runtime.
 
## How the attack roll is made. Melee uses THREAT for reach and ignores cover;
## ranged uses RANGE and respects cover. (CQB/Rifle/etc. are all RANGED.)
enum AttackKind {
	MELEE,
	RANGED,
}

## If this weapon's targeting will ask the user for a unit or a tile to choose.
enum AttackTarget {
	UNIT,
	TILE
}
 
## Shape of the affected area.
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

@export var targeting : AttackTarget = AttackTarget.UNIT
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
 
 
## SMART attacks must be jammed, not dodged: they hit E-DEFENSE.
func targets_e_defense() -> bool:
	return has_tag(WeaponTag.SMART)
 
 
## Cover applies only to ranged, non-SEEKING attacks (checked at roll time).
func ignores_cover() -> bool:
	return is_melee() or has_tag(WeaponTag.SEEKING)
 



func display_name() -> String:
	return profile_name





## Provides information to the kind of choice that is asked when a target is chosen.
func target_choice_kind() -> Choice.Kind:
	match targeting:
		WeaponProfile.AttackTarget.UNIT:
			return Choice.Kind.PICK_TARGET
		_:
			return Choice.Kind.PICK_AOE_ANCHOR

## Provides the choice of targets from this weapon's specifications.
func target_choice(attacker : Unit) -> Choice:
	## Targeting rules are essentially universal.
	var candidates
	
	match pattern:
		WeaponProfile.Pattern.NONE:
			candidates = candidate_units(attacker)
	# TODO: AoE
	
	var choice = Choice.new(candidates, target_choice_kind())
	return choice

## Turns a confirmed pick into the normalized TargetSet.
## "Knowing all that we know about this weapon, and knowing that person X is
## targeting object Y, what would be the final targetset?".
func target_set(attacker: Unit, pick: Variant) -> TargetSet:
	var result := TargetSet.new()
	match target_choice_kind():
		Choice.Kind.PICK_TARGET:
			result.origin = attacker._position
			result.units = [pick as Unit]
		Choice.Kind.PICK_AOE_ANCHOR:
			result.origin = pick as Vector2i # KNOCKBACK and BLAST cover measure from here
			#result.tiles = footprint(pick)
			#result.units = _units_on(result.tiles)
	return result

## Direct attacks: every unit the profile can legally reach. Allies are
## deliberately included (friendly fire is legal); sorting or warning about
## that is the presenter's business, not the rules'.
func candidate_units(attacker : Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit: Unit in BattleEngine.world.get_units():
		if unit == attacker:
			continue # "characters can't target themselves" unless a rule says so
		if not is_in_reach(attacker._position, unit._position):
			continue
		if not _passes_los(unit._position):
			continue
		# ORDNANCE "can't be used against targets in engagement with the user".
		if has_tag(WeaponProfile.WeaponTag.ORDNANCE) and _engaged(attacker, unit):
			continue
		result.append(unit)
	return result

## Pattern attacks: the tiles the area can be anchored on.
func candidate_tiles(attacker : Unit, grid : HexGrid) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	match pattern:
		WeaponProfile.Pattern.BLAST:
			# "drawn from a point within RANGE and line of sight" of the attacker.
			for coord: Vector2i in grid.tiles:
				if is_in_reach(attacker._position, coord) and _passes_los(coord):
					result.append(coord)
		WeaponProfile.Pattern.CONE, WeaponProfile.Pattern.LINE:
			# A direction pick: hovering an endpoint tile fixes the orientation.
			# TODO(hex geometry): the book defines CONE/LINE on squares. Decide
			# the hex wedge/line shape ONCE, inside footprint(); the candidate
			# endpoints then fall out of that same decision.
			pass
		_:
			pass
	return result

## Rolls every packet up front.
func roll_damage() -> Array[Dictionary]:
	var rolls: Array[Dictionary] = []
	for packet: DamagePacket in damage_packets:
		var a := packet.roll()
		rolls.append({"packet": packet, "normal": a, "crit": null})
	return rolls

## Rolls every packet up front, twice, take highest.
func roll_damage_crit() -> Array[Dictionary]:
	var rolls: Array[Dictionary] = []
	for packet: DamagePacket in damage_packets:
		var a := packet.roll()
		var b := packet.roll()
		rolls.append({"packet": packet, "normal": a, "crit": maxi(a, b)})
	return rolls

# --- helpers ------------------------------------------------------------------
 
# TODO: RANGE is measured from a character's EDGE, so Size 2+ units both
# reach and are reached slightly farther. Revisit when multi-tile units exist.
func is_in_reach(from : Vector2i, to : Vector2i) -> bool:
	var d := HexGrid.distance(from, to)
	if d < min_range:
		return false # Apocalypse Rail-style "cannot be fired at targets within X"
	return d <= reach()
 
# TODO
func _passes_los(_coord: Vector2i) -> bool:
	return true
 
 
## Engagement, minimally: adjacent and hostile.
func _engaged(first_unit : Unit, second_unit : Unit) -> bool:
	if first_unit._faction == second_unit._faction:
		return false
	return HexGrid.distance(first_unit._position, second_unit._position) == 1
 
 
func _units_on(tiles: Array[Vector2i]) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit: Unit in BattleEngine.world.get_units():
		if tiles.has(unit._position):
			result.append(unit)
	return result
