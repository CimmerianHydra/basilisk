extends UnitFilter
class_name FilterEnemyByRange

@export var enemies_of_unit : Unit
@export var radius : int = 0

func filter_array(units : Array[Unit]) -> Array[Unit]:
	var to_return : Array[Unit] = []
	var grid := get_tree().get_first_node_in_group(HexGrid.GROUP) as HexGrid3D
	var position_component = enemies_of_unit.find_child("GridPositionComponent") as GridPositionComponent
	var from = position_component.coord
	for unit in units:
		var position_component_of_target = unit.find_child("GridPositionComponent") as GridPositionComponent
		var to = position_component_of_target.coord
		if grid.grid.layout.distance(from, to) <= radius and enemies_of_unit.team != unit.team:
			to_return.append(unit)
	return to_return

func filter(unit : Unit) -> bool:
	var grid := get_tree().get_first_node_in_group(HexGrid.GROUP) as HexGrid3D
	var position_component = enemies_of_unit.find_child("GridPositionComponent") as GridPositionComponent
	var from = position_component.coord
	var units_in_range = grid.get_units_within_range(from, radius)
	return enemies_of_unit.team != unit.team and unit in units_in_range
