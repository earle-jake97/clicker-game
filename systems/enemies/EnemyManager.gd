extends Node

enum variant {MONEY, NORMAL}
var enemy_list: Array = []
signal optimize
signal kill_all
signal magnet_all


func register(enemy):
	enemy_list.append(enemy)
	if enemy_list.size() == 50:
		optimize.emit()

func unregister(enemy):
	enemy_list.erase(enemy)

func get_all_enemies():
	return enemy_list

func clear_list():
	enemy_list = []

func kill_all_enemies_in_list():
	kill_all.emit()
	
func signal_magnet():
	magnet_all.emit()
	

func get_terrain_node():
	return get_tree().get_first_node_in_group("base_terrain")

func get_valid_tile_near_point(pos: Vector2, max_radius: int = 10):
	var terrain_node = get_terrain_node()
	var start_cell = terrain_node.local_to_map(terrain_node.to_local(pos))
	var visited = {}
	var queue: Array[Vector2i] = []
	queue.push_back(start_cell)
	visited[start_cell] = true
	
	var directions := [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, 1),
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1)
	]
	
	while queue.size() > 0:
		var cell: Vector2i = queue.pop_front()

		var dist = abs(cell.x - start_cell.x) + abs(cell.y - start_cell.y)
		if dist > max_radius:
			continue

		var cell_data = terrain_node.get_cell_tile_data(cell)
		if cell_data and cell_data.get_custom_data("inhabitable"):
			var valid_pos = terrain_node.map_to_local(cell)
			return terrain_node.to_global(valid_pos)

		for d in directions:
			var next = cell + d
			if not visited.has(next):
				visited[next] = true
				queue.push_back(next)
	print("Couldn't find a valid tile...")
	return Vector2.ZERO
