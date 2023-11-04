extends TileMap

const main_layer = 0
const source_id = 1
const single_gear_source_id = 1
const gear_coords = Vector2i(0,0)
const rotates_clockwise_word = "rotates_clockwise"

enum GearColors{Green=1,Red=2}
enum GearProperty{Clockwise=0,CounterClockwise=1,Stopped=2,Unset=3}

const clockwise := 1
const counter_clockwise := -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func get_neighbors(cell: Vector2i) -> Array:
	return get_surrounding_cells(cell)
	
func is_stuck(pos: Vector2i):
	var last_had_gear = false
	for other in get_neighbors(pos) + [get_neighbors(pos)[0]]:
		#print(other)
		if get_cell_source_id(main_layer, other) != -1:
			if last_had_gear:
				return true
			last_had_gear = true
		else:
			last_had_gear = false
			
	return false

func set_as_counterclockwise(spot:Vector2i):
	set_cell(main_layer, spot, single_gear_source_id, gear_coords, GearProperty.CounterClockwise)

func set_as_clockwise(spot:Vector2i):
	set_cell(main_layer, spot, single_gear_source_id, gear_coords, GearProperty.Clockwise)

func set_as_stopped(spot:Vector2i):
	set_cell(main_layer, spot, single_gear_source_id, gear_coords, GearProperty.Stopped)
	

func rotation_dfs(start: Vector2i, rotation_direction=clockwise):
	var seen := {}
	var rotation_directions = {start: {rotation_direction: true}}
	var fringe = [start]
	var everything_is_bad = false
	while fringe.size() > 0:
		var current = fringe.pop_back()
		if get_cell_alternative_tile(main_layer, current) == -1:
			continue
		if current in seen:
			continue
		if rotation_directions[current].size() > 1:
			everything_is_bad = true
		seen[current] = true
		
		for other in get_neighbors(current):
			if other not in rotation_directions:
				rotation_directions[other] = {}
			rotation_directions[other][-1 * rotation_directions[current].keys()[0]] = true
			fringe.append_array(get_neighbors(current))
	
	if everything_is_bad:
		var bad_spots: Array[Vector2i] = []
		for bad_spot in seen:
			bad_spots.append(bad_spot)
		#print_debug("bad spots", bad_spots)
		set_all_in_list_to_stopped(bad_spots)
	else:
		set_all_in_list_to_corresponding_value(
					get_first_value_of_each_from_dict(intersection(rotation_directions, seen)), 
					clockwise, counter_clockwise
		)
		

func intersection(dict_to_keep_values_from, dict2):
	var ret = {}
	for spot in dict_to_keep_values_from:
		if spot in dict2:
			ret[spot] = dict_to_keep_values_from[spot]
	return ret
		

func get_first_value_of_each_from_dict(dict):
	var ret = {}
	for spot in dict:
		ret[spot] = dict[spot].keys()[0]
	return ret
		
func set_all_in_list_to_corresponding_value(spot_to_value: Dictionary, clockwise_val, counter_clockwise_val):
	for spot in spot_to_value:
		if spot_to_value[spot] == clockwise_val:
			set_as_clockwise(spot)
		else:
			set_as_counterclockwise(spot)
		#await get_tree().create_timer(.4).timeout
			

func set_all_in_list_to_stopped(bad_list: Array[Vector2i]):
	for spot in bad_list:
		#await get_tree().create_timer(.4).timeout
		set_as_stopped(spot)

func get_rotation_direction_for_spot(spot:Vector2i):
	var cell_data = get_cell_tile_data(main_layer, spot)
	if cell_data.get_custom_data(rotates_clockwise_word):
		return clockwise
	return counter_clockwise

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var seen = {} 
	for current_cell in get_used_cells(main_layer):
		if get_cell_alternative_tile(main_layer, current_cell) != -1:
			if is_stuck(current_cell):
				set_as_stopped(current_cell)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var global_clicked = get_global_mouse_position()
			var pos_clicked = local_to_map(to_local(global_clicked))
			print(pos_clicked)
			var current_atlas_coords = get_cell_atlas_coords(main_layer, pos_clicked)
			var current_tile_alt = get_cell_alternative_tile(main_layer, pos_clicked)
			if event.button_index == MOUSE_BUTTON_LEFT:
				if current_tile_alt == -1:
					set_as_clockwise(pos_clicked)
					var first_neighbor = get_first_existing_neighbor(pos_clicked)
					
					var adj_rotation_direction = get_rotation_direction_for_spot(
													first_neighbor
												) if first_neighbor != null else counter_clockwise
					rotation_dfs(pos_clicked, -1*adj_rotation_direction)
					queue_redraw()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				if current_tile_alt != -1:
					var deleted_spot_rotation_direction = get_rotation_direction_for_spot(pos_clicked)
					erase_cell(main_layer, pos_clicked)
					var first_neigh = get_first_existing_neighbor(pos_clicked)
					if first_neigh != null:
						rotation_dfs(first_neigh, -1 * deleted_spot_rotation_direction)
					queue_redraw()

func get_first_existing_neighbor(spot:Vector2i):
	for neigh in get_neighbors(spot):
		if get_cell_alternative_tile(main_layer, neigh) != -1:
			return neigh
	return null
				
