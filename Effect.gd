extends Resource
class_name Effect

## Effects are generalized commands that can mutate the state of the game and
## generate Events.
## 
## At their core, Effects only contain data. It is the EffectResolver node that
## takes Effects and mutates the state of the game while generating events.
##
## Obviously since there's many Effects and since GDScript is built the way it is
## we must store the behavior of the effect on the script of the effect itself,
## so that the EffectResolver script isn't bloated.
## 
## Very importantly, the EffectResolver makes a copy of the Effect and mutates
## the world off of that. This way, multiple calls of the same Effect result in
## exactly the same predictable outcome rather than depending on the history of
## the effect.

const NONE = null

var source : Variant
var target : Variant

func sources(_world : World) -> void: return
func targets(_world : World) -> void: return
func resolve(_world : World) -> void: return
