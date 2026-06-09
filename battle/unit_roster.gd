extends Node3D
class_name UnitRoster

const GROUP: StringName = &"unit_roster"

signal unit_clicked(unit: Unit)

var _units : Array[Unit] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(GROUP)
	register_units()

func register_units() -> void:
	for child in get_children():
		if child is Unit:
			child.connect("clicked", func(): _on_unit_clicked(child) )
			_units.append(child)

func get_units() -> Array[Unit]:
	return _units

func _on_unit_clicked(unit: Unit) -> void:
	print("Player clicked on Unit '%s'." % unit.name)
	unit_clicked.emit(unit)

# -------- Unit clicking helpers ------- #

func set_units_clickable() -> void:
	for unit in _units:
		unit.set_clickable(true)

func set_units_unclickable() -> void:
	for unit in _units:
		unit.set_clickable(false)
