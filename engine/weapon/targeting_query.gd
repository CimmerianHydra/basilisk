class_name TargetingQuery
extends RefCounted
## Answers, for one attacker firing one profile: which interaction the UI
## should run, what the legal picks are, and what a confirmed pick expands
## into. Actions stay rules-blind — Skirmish just routes this to the matching
## Choice kind and hands the result to resolution.
## Intended path: res://engine/targeting/targeting_query.gd
 
## Which picker the choice system should present.
enum PickKind {
	PICK_UNIT,     ## Direct attack: click a unit.
	PICK_ANCHOR,   ## BLAST picks a point; CONE/LINE pick a tile fixing a direction.
	CONFIRM_ONLY,  ## BURST: the footprint is fixed on the user; nothing to pick.
}
 
var attacker: Unit
var profile: WeaponProfile
 
var _grid: HexGrid
 
 
static func build(p_attacker: Unit, p_profile: WeaponProfile) -> TargetingQuery:
	var query := TargetingQuery.new()
	query.attacker = p_attacker
	query.profile = p_profile
	query._grid = BattleEngine.world._grid
	return query
 
 
func pick_kind() -> PickKind:
	match profile.pattern:
		WeaponProfile.Pattern.NONE:
			return PickKind.PICK_UNIT
		WeaponProfile.Pattern.BURST:
			return PickKind.CONFIRM_ONLY
		_:
			return PickKind.PICK_ANCHOR
 
 
# --- candidates -------------------------------------------------------------
 
## Direct attacks: every unit the profile can legally reach. Allies are
## deliberately included (friendly fire is legal); sorting or warning about
## them is the presenter's business, not the rules'.
func candidate_units() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit: Unit in BattleEngine.world.get_units():
		if unit == attacker:
			continue # "characters can't target themselves" unless a rule says so
		if not _in_reach(unit._position):
			continue
		if not _passes_los(unit._position):
			continue
		# ORDNANCE "can't be used against targets in engagement with the user".
		if profile.has_tag(WeaponProfile.WeaponTag.ORDNANCE) and _engaged_with(unit):
			continue
		result.append(unit)
	return result
 
 
## Pattern attacks: the tiles the area can be anchored on.
func candidate_anchors() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	match profile.pattern:
		WeaponProfile.Pattern.BLAST:
			# "drawn from a point within RANGE and line of sight" of the attacker.
			for coord: Vector2i in _grid.tiles:
				if _in_reach(coord) and _passes_los(coord):
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
 
 
## The area produced by anchoring at `anchor` — both the resolver's affected
## tiles and the picker's hover preview, so they can never disagree.
func footprint(anchor: Vector2i) -> Array[Vector2i]:
	match profile.pattern:
		WeaponProfile.Pattern.BLAST:
			return _disk(anchor, profile.pattern_size) # includes the center
		WeaponProfile.Pattern.BURST:
			# "centered on ... the user", but "the user is not affected by the
			# attack unless specified" — so the footprint excludes their tile.
			var area := _disk(attacker._position, profile.pattern_size)
			area.erase(attacker._position)
			return area
		WeaponProfile.Pattern.CONE, WeaponProfile.Pattern.LINE:
			return [] # TODO(hex geometry): see candidate_anchors().
		_:
			return []
 
 
# --- expansion ---------------------------------------------------------------
 
## Turns a confirmed pick into the normalized TargetSet.
func expand(pick: Variant) -> TargetSet:
	var result := TargetSet.new()
	match pick_kind():
		PickKind.PICK_UNIT:
			result.origin = attacker._position
			result.units = [pick as Unit]
		PickKind.PICK_ANCHOR:
			result.origin = pick # KNOCKBACK and BLAST cover measure from here
			result.tiles = footprint(pick)
			result.units = _units_on(result.tiles)
		PickKind.CONFIRM_ONLY:
			result.origin = attacker._position
			result.tiles = footprint(attacker._position)
			result.units = _units_on(result.tiles) # footprint already excludes the user
	return result
 
 
# --- helpers ------------------------------------------------------------------
 
func _in_reach(coord: Vector2i) -> bool:
	var d := _grid.distance(attacker._position, coord)
	if d < profile.min_range:
		return false # Apocalypse Rail-style "cannot be fired at targets within X"
	return d <= profile.reach()
	# TODO: RANGE is measured from a character's EDGE, so Size 2+ units both
	# reach and are reached slightly farther. Revisit when multi-tile units land.
 
 
func _passes_los(coord: Vector2i) -> bool:
	match profile.los_policy():
		WeaponProfile.LosPolicy.SEEKING, WeaponProfile.LosPolicy.ARCING:
			# Neither needs line of sight; both still need a physically possible
			# path ("can't fire through 50 feet of bulkhead").
			# TODO: path-possibility check once sealed rooms are representable.
			return true
		_:
			# TODO: hook HexGrid.has_line_of_sight once it's re-enabled; the
			# call site is ready. Permissive until then.
			return true
 
 
## Engagement, minimally: adjacent and hostile.
func _engaged_with(unit: Unit) -> bool:
	if unit._faction == attacker._faction:
		return false
	return _grid.distance(attacker._position, unit._position) == 1
 
 
func _units_on(tiles: Array[Vector2i]) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit: Unit in BattleEngine.world.get_units():
		if tiles.has(unit._position):
			result.append(unit)
	return result
 
 
## All existing tiles within `radius` of `center`, center included.
func _disk(center: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for coord: Vector2i in _grid.tiles:
		if _grid.distance(center, coord) <= radius:
			result.append(coord)
	return result
