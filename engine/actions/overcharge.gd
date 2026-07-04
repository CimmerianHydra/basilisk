extends BattleAction
class_name Overcharge

func execute() -> void:
	var oc := Overcharged.new(_unit)
	_unit.add_modifier(oc)

func display_name() -> String: return "Overcharge"
