extends ActionComponent
class_name TargetUnits

signal selection_completed

@export var replace_targets: bool = true
@export var max_targets: int = 1
@export var min_targets: int = 1

@export_category("Filter")
## The "standard filter" is the one used by most actions: the component
## directly filters for the enemies of this unit within a certain range.
@export var unit_filter: UnitFilter = UnitFilter.new()

var _selected: Array[Unit] = []


func validate(_ctx: Dictionary) -> bool:
	return true


func execute(ctx: Dictionary) -> void:
	# WIP: start a "select unit" session, wait for completion signal.
	# we can model the unit selection session after this action component.
	_selected.clear()
	
	_connect_to_turn_state()
	_connect_to_unit_roster()
	
	await selection_completed

	_disconnect_from_unit_roster()
	_disconnect_from_turn_state()
	
	if replace_targets:
		ctx[Action.TARGETS_KEY] = _selected.duplicate()
	else:
		for unit in _selected:
			ctx[Action.TARGETS_KEY].append(unit)
	
	_selected.clear()
	super(ctx)


# ------ Private helpers ------ #

func _connect_to_unit_roster() -> void:
	_selected.clear()
	var roster := get_tree().get_first_node_in_group(UnitRoster.GROUP) as UnitRoster
	if roster == null:
		push_error("'%s' component couldn't find UnitRoster." % self.name)
		return
	roster.set_units_clickable()
	roster.unit_clicked.connect(_on_unit_selected)
	
	var filtered_units = _apply_filter(roster.get_units())
	
	for unit in filtered_units:
		unit.highlight_start()


func _disconnect_from_unit_roster() -> void:
	var roster := get_tree().get_first_node_in_group(UnitRoster.GROUP) as UnitRoster
	if roster == null:
		push_error("'%s' component couldn't find UnitRoster." % self.name)
		return
	roster.unit_clicked.disconnect(_on_unit_selected)
	
	# WIP: make this into a function on UnitRoster so we are agnostic about other Units
	for unit in roster.get_units():
		unit.highlight_stop()


func _on_unit_selected(unit: Unit) -> void:
	if not is_instance_valid(unit):
		return
	if not unit_filter.filter(unit):
		return
	
	# Toggle behavior — clicking a selected target deselects it.
	if unit in _selected:
		_selected.erase(unit)
		#unit.select_for_target_select(false)
		return

	_selected.append(unit)
	#unit.select_for_target_select(true)

	if _selected.size() >= max_targets:
		selection_completed.emit()

func _apply_filter(unit_array : Array[Unit]) -> Array[Unit]:
	return unit_filter.filter_array(unit_array)


func _connect_to_turn_state() -> void:
	var turn_state := get_tree().get_first_node_in_group(TurnState.GROUP) as TurnState
	turn_state.transition_to("PlayerUnitSelect")

func _disconnect_from_turn_state() -> void:
	var turn_state := get_tree().get_first_node_in_group(TurnState.GROUP) as TurnState
	turn_state.transition_to("PlayerTurn")
