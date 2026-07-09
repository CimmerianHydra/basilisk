class_name DamagePacket
extends Resource
## One source of damage on a weapon profile: <dice>d<sides> + <flat> of one type.
##
## A profile can carry several packets (the Bolt Thrower rolls 2d6 kinetic AND
## 1d6 explosive), and the crit rule keeps the highest result "from each source
## of damage" — so packets roll, crit, and eventually halve independently.
## Intended path: res://engine/unit/damage_packet.gd
 
@export var dice: int = 0
@export var sides: int = 0
@export var flat: int = 0
@export var type: Damage.Type = Damage.Type.KINETIC
 
 
## Rolls this packet once. RNG goes through the world so seeding / projected
## timelines keep working.
func roll() -> int:
	var total := flat
	for _i in dice:
		total += BattleEngine.world.d(sides)
	return total
 
 
func to_display() -> String:
	var text := ""
	if dice > 0:
		text = "%dd%d" % [dice, sides]
	if flat > 0:
		text += ("+%d" % flat) if text != "" else str(flat)
	return "%s %s" % [text, Damage.display_name(type)]
