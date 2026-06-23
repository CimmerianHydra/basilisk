extends Resource
class_name Gate

## Gates are used in GatedEffects to determine whether the effect goes through.
## For example, they can be used in all sorts of attack rolls to verify that
## the attack roll is above the target's evasion.

func success() -> bool : return false
func description() -> String : return ""
