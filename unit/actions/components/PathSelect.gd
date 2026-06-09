extends ActionComponent
class_name PathMove

signal goal_found(coord)

@export var spend_move_budget : bool = false

var _reachable : Dictionary = {}
var _grid : HexGrid3D
var _goal : Vector2i

func execute(ctx: Dictionary) -> void:
	_reachable = {}
	_grid = get_tree().get_first_node_in_group(HexGrid.GROUP)
	var targets = ctx[Action.TARGETS_KEY]
	for target in targets:
		var target_grid_component : GridPositionComponent = target.grid_position_component
		var target_move_component : MoveComponent = target.move_component
		var current_position = target_grid_component.coord
		
		var movement_budget = target_move_component.move_budget
		if spend_move_budget:
			movement_budget = target_move_component.get_remaining_budget()
		
		var movement_profile = target_move_component.profile
		var speed_of_unit = target_move_component.speed
		
		_reachable = _grid.get_reachable(current_position, movement_budget, movement_profile)
		_grid.connect("tile_clicked", _on_tile_clicked)
		var highlightable : Array[Vector2i] = []
		for coord in _reachable.keys():
			highlightable.append(coord)
		_grid.highlight_tiles(highlightable)
		await goal_found
		
		var path = _grid.find_path(current_position, _goal, movement_profile)
		await trigger("movement_start", ctx)
		
		if spend_move_budget:
			var spent = _reachable[_goal]
			target_move_component.spend_budget(spent)
		
		for coord in path:
			var destination = _grid.coord_to_world(coord)
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property(target, "position", destination, 1/speed_of_unit)
			await tween.finished
			var height = _grid.grid.get_height(coord)
			target_grid_component.coord = coord
			target_grid_component.height = height
			_grid.move_unit(target, coord)
		
		_grid.disconnect("tile_clicked", _on_tile_clicked)
		_grid.higlight_off()

func _on_tile_clicked(coord, button):
	if coord in _reachable:
		if button == MOUSE_BUTTON_LEFT:
			_goal = coord
			goal_found.emit(coord)
