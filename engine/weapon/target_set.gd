class_name TargetSet
extends RefCounted
## Normalized output of targeting, whatever the weapon's delivery. Resolution
## only ever consumes this shape: a single-target rifle is just the degenerate
## case (one unit, no tiles).
## Intended path: res://engine/targeting/target_set.gd
 
## The attack's point of origin: the attacker's tile for direct, BURST, CONE
## and LINE attacks, or the anchor point of a BLAST. KNOCKBACK pushes directly
## away from here, and BLAST measures per-target cover and LoS from here rather
## than from the attacker.
var origin: Vector2i
 
## Affected footprint; empty for direct (single-unit) attacks. Kept for the
## resolution loop AND for the view layer (area flash, lingering-cloud effects
## later).
var tiles: Array[Vector2i] = []
 
## Everyone a separate attack roll is made against, allies included — friendly
## fire is legal in Lancer.
var units: Array[Unit] = []
 
 
## Bonus damage is halved "if there are multiple characters affected".
func is_multi_target() -> bool:
	return units.size() > 1
 
