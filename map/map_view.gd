extends Node2D

@onready var end_top: Marker2D = $Markers/EndTop
@onready var end_bot: Marker2D = $Markers/EndBot
@onready var markers: Node2D = $Markers



const MAP_NODE_SCENE = preload("res://map/map_node.tscn")
const BOSS = preload("res://map/boss.png")
const EVENT = preload("res://map/event.png")
const HORDE = preload("res://map/horde.png")
const ITEM = preload("res://map/item.png")
const MINIBOSS = preload("res://map/miniboss.png")
const SHOP = preload("res://map/shop.png")
const TIME = preload("res://map/time.png")
const MAP_LINE = preload("res://map/map_line.tscn")
const CLEARED = preload("res://map/cleared.png")
const START = preload("res://map/start.png")
var decorative_textures: Array[Texture2D] = []

var time_instance = false
var miniboss_instance = false
var event_count = 0
var item_count = 0
var shop_count = 0

var current_layer = 0
var layers
var all_nodes: Array[Node2D] = []
var layer_nodes = []  # <-- untyped to avoid nested typed collection error

func _ready() -> void:
	HealthBar.button.visible = false
	HealthBar.fast_forward = false
	load_decorative_textures_from_folder("res://map/decorations/")
	GameState.on_map_screen = true
	layers = markers.get_children()
	current_layer = 0

	if MapState.nodes.is_empty():
		generate_map()
		save_map_to_state()
	else:
		for data in MapState.nodes:
			var node = MAP_NODE_SCENE.instantiate()
			node.map_id = data["id"]
			node.room_type = data["room_type"]
			node.global_position = data["position"]
			node.state = data["state"]
			node.is_connected = data["is_connected"]
				
			node.connect("trigger_save", Callable(self, "_on_trigger_save"))
			all_nodes.append(node)
			self.add_child(node)
			node.z_index = 11

		
		# Reconnect nodes by ID
		for i in range(MapState.nodes.size()):
			var data = MapState.nodes[i]
			var node = all_nodes[i]
			for conn_id in data["connections"]:
				if conn_id == null:
					push_error("Null conn_id in node %s" % data["id"])
					continue
				else:
					node.connections.append(all_nodes[conn_id])
					draw_connection_line(node.global_position, all_nodes[conn_id].global_position)
func _process(delta: float) -> void:
	if GameState.endless_mode: 
		queue_free()

func generate_map():
	for layer in layers:
		generate_nodes()
	
	create_start_node()
	
	connect_nodes_with_guaranteed_paths()
	connect_extra_nodes()
	spawn_decorations()

func generate_nodes():
	var layer_x_spacing = 400
	var vertical_center = 324
	var vertical_spread = 200
	var min_distance = 80
	var max_attempts = 10

	var layer_x = layers[current_layer].global_position.x
	var layer_amount = randi_range(2, 3)
	var placed_y_positions := []
	var current_layer_nodes: Array[Node2D] = []

	for i in range(layer_amount):
		var node_y_offset = 0.0
		var attempts = 0
		while attempts < max_attempts:
			var try_y = vertical_center + randf_range(-vertical_spread, vertical_spread)
			var too_close = false
			for y in placed_y_positions:
				if abs(y - try_y) < min_distance:
					too_close = true
					break
			if not too_close:
				node_y_offset = try_y
				placed_y_positions.append(node_y_offset)
				break
			attempts += 1

		if attempts == max_attempts:
			node_y_offset = vertical_center

		var node = MAP_NODE_SCENE.instantiate()
		var node_location = Vector2(layer_x + randf_range(-10, 10), node_y_offset)

		var type = generate_random_node_type()
		node.room_type = type.room_name
		self.add_child(node)
		node.global_position = node_location
		node.z_index = 11
		node.connect("trigger_save", Callable(self, "_on_trigger_save"))
		node.map_id = all_nodes.size()
		all_nodes.append(node)
		current_layer_nodes.append(node)

		if current_layer == 7:
			node.global_position.y = vertical_center
			layer_nodes.append(current_layer_nodes)
			return

	current_layer += 1
	layer_nodes.append(current_layer_nodes)

func connect_nodes_with_guaranteed_paths():
	for i in range(layer_nodes.size() - 2):  # Skip the last two layers (preboss and boss)
		var current_layer = layer_nodes[i]
		var next_layer = layer_nodes[i + 1]
		var closest_node
		for node in current_layer:
			var closest = null
			var closest_dist = INF
			for target in next_layer:
				var d = node.global_position.distance_to(target.global_position)
				if d < closest_dist:
					closest = target
					closest_dist = d
					closest_node = target
			if closest:
				draw_connection_line(node.global_position, closest.global_position)
				node.connections.append(closest_node)
				closest.connections.append(node)

	# Manual connections for preboss layer
	var boss_layer = layer_nodes[-1]
	var preboss_layer = layer_nodes[-2]
	if boss_layer.size() == 1:
		var boss = boss_layer[0]
		for node in preboss_layer:
			draw_connection_line(node.global_position, boss.global_position)
			node.connections.append(boss)
			boss.connections.append(node)

	# Explicitly connect preboss nodes in sequence only (0->1, 1->2 if exists)
	if preboss_layer.size() >= 2:
		draw_connection_line(preboss_layer[0].global_position, preboss_layer[1].global_position)
		preboss_layer[0].connections.append(preboss_layer[1])
	if preboss_layer.size() == 3:
		draw_connection_line(preboss_layer[1].global_position, preboss_layer[2].global_position)
		preboss_layer[1].connections.append(preboss_layer[2])


func connect_extra_nodes():
	var radius = 158.5
	
	for i in range(all_nodes.size()):
		var node_a = all_nodes[i]
		for j in range(i + 1, all_nodes.size()):
			var node_b = all_nodes[j]
			if node_a == node_b:
				continue
			if node_a.room_type == "boss" or node_b.room_type == "boss":
				continue  # Don't connect to or from boss unless explicitly
			var distance = node_a.global_position.distance_to(node_b.global_position)
			if distance <= radius and not path_already_connected(node_a, node_b):
				if not line_intersects_node_midpoint(node_a.global_position, node_b.global_position, [node_a, node_b]):
					draw_connection_line(node_a.global_position, node_b.global_position)
					node_a.connections.append(node_b)
					node_b.connections.append(node_a)

func path_already_connected(a: Node2D, b: Node2D) -> bool:
	for child in get_children():
		if child is Line2D and child.get_point_count() == 2:
			var p1 = child.get_point_position(0)
			var p2 = child.get_point_position(1)
			var is_same = (
				(p1 == a.global_position and p2 == b.global_position) or
				(p1 == b.global_position and p2 == a.global_position)
			)
			if is_same:
				return true
	return false

func line_intersects_node_midpoint(from_pos: Vector2, to_pos: Vector2, ignore: Array) -> bool:
	var segment = from_pos.distance_to(to_pos)
	for node in all_nodes:
		if node in ignore:
			continue
		var node_pos = node.global_position
		var closest_point = Geometry2D.get_closest_point_to_segment(node_pos, from_pos, to_pos)
		var is_between = (
			node_pos.distance_to(from_pos) < segment and
			node_pos.distance_to(to_pos) < segment
		)
		if is_between and node_pos.distance_to(closest_point) < 30.0:
			return true
	return false

func draw_connection_line(from_pos: Vector2, to_pos: Vector2):
	var line = MAP_LINE.instantiate()
	add_child(line)
	line.global_position = from_pos
	line.z_index = 9
	line.width = 4
	line.remove_point(0)
	line.remove_point(0)
	line.add_point(to_pos)
	line.add_point(to_pos)
	line.set_point_position(0, Vector2.ZERO)
	line.set_point_position(1, to_pos - from_pos)

func line_intersects_any_node(from_pos: Vector2, to_pos: Vector2, ignore_node: Node2D) -> bool:
	for node in all_nodes:
		if node == ignore_node:
			continue
		var node_pos = node.global_position
		var closest_point = Geometry2D.get_closest_point_to_segment(node_pos, from_pos, to_pos)
		if node_pos.distance_to(closest_point) < 40.0:
			return true
	return false

func generate_random_node_type():
	var ran_room = randf()
	if current_layer == 0:
		if ran_room <= 0.01 and not time_instance:
			time_instance = true
			return get_time()
		else:
			return get_horde()

	elif current_layer == 1:
		if ran_room <= 0.5 and item_count == 0:
			item_count += 1
			return get_item()
		else:
			return get_horde()

	elif current_layer == 2:
		if item_count < 1:
			item_count += 1
			return get_item()
		elif ran_room <= 0.05 and not time_instance:
			time_instance = true
			return get_time()
		elif ran_room <= 0.55 and shop_count == 0:
			shop_count += 1
			return get_shop()
		else:
			return get_horde()

	elif current_layer == 3:
		if shop_count < 1:
			shop_count += 1
			return get_shop()
		if ran_room <= 0.1 and not miniboss_instance:
			miniboss_instance = true
			return get_miniboss()
		elif ran_room <= 0.2 and not time_instance:
			time_instance = true
			return get_time()
		elif ran_room <= 0.5 and item_count < 2:
			item_count += 1
			return get_item()
		elif ran_room <= 0.6 and shop_count < 2:
			shop_count += 1
			return get_shop()
		elif ran_room <= 0.67 and event_count < 1:
			event_count += 1
			return get_event()
		else:
			return get_horde()

	elif current_layer == 4:
		if ran_room <= 0.15 and not miniboss_instance:
			miniboss_instance = true
			return get_miniboss()
		elif ran_room <= 0.25 and not time_instance:
			time_instance = true
			return get_time()
		elif ran_room <= 0.55 and item_count < 3:
			item_count += 1
			return get_item()
		elif ran_room <= 0.85 and shop_count < 2:
			shop_count += 1
			return get_shop()
		elif ran_room <= 0.9 and event_count < 1:
			event_count += 1
			return get_event()
		else:
			return get_horde()

	elif current_layer == 5:
		if ran_room <= 0.2 and not miniboss_instance:
			miniboss_instance = true
			return get_miniboss()
		elif ran_room <= 0.3 and not time_instance:
			time_instance = true
			return get_time()
		elif ran_room <= 0.55 and item_count < 3:
			item_count += 1
			return get_item()
		elif ran_room <= 0.70 and shop_count < 2:
			shop_count += 1
			return get_shop()
		elif ran_room <= 0.76 and event_count < 2:
			event_count += 1
			return get_event()
		else:
			return get_horde()

	elif current_layer == 6:
		if shop_count < 2:
			return get_shop()
		elif item_count < 2:
			return get_item()
		elif ran_room <= 0.4 and not miniboss_instance:
			miniboss_instance = true
			return get_miniboss()
		elif ran_room <= 0.65 and not time_instance:
			time_instance = true
			return get_time()
		elif ran_room <= 0.70 and item_count < 3:
			item_count += 1
			return get_item()
		elif ran_room <= 0.90 and shop_count < 2:
			shop_count += 1
			return get_shop()
		elif ran_room <= 0.95 and event_count < 2:
			event_count += 1
			return get_event()
		else:
			return get_horde()
	else:
		return get_boss()

func get_horde(): return {"room_name": "horde", "sprite": HORDE}
func get_time(): return {"room_name": "time", "sprite": TIME}
func get_event(): return {"room_name": "event", "sprite": EVENT}
func get_miniboss(): return {"room_name": "miniboss", "sprite": MINIBOSS}
func get_item(): return {"room_name": "item", "sprite": ITEM}
func get_shop(): return {"room_name": "shop", "sprite": SHOP}
func get_boss(): return {"room_name": "boss", "sprite": BOSS}

func create_start_node():
	var layer_x = layers[0].global_position.x
	var vertical_center = 324
	var node = MAP_NODE_SCENE.instantiate()
	node.room_type = "start"
	self.add_child(node)
	node.z_index = 10
	node.map_id = -1
	node.connect("trigger_save", Callable(self, "_on_trigger_save"))

	# Position it to the left of the first layer
	node.global_position = Vector2(layer_x - 100, vertical_center)

	# Save it as a special layer
	var start_layer: Array[Node2D] = [node]
	layer_nodes.insert(0, start_layer)
	all_nodes.append(node)
	node.is_connected = true
	

	# Connect it to every node in what used to be the first layer (now second)
	var first_layer = layer_nodes[1]
	for next_node in first_layer:
		draw_connection_line(node.global_position, next_node.global_position)
		node.connections.append(next_node)

func spawn_decorations(
	num_decorations := 40,
	bounds := Rect2(Vector2(40, 70), Vector2(1170, 680)),
	avoid_positions: Array[Vector2] = [],
	avoid_radius := 250
):
	if decorative_textures.is_empty():
		return
	num_decorations = min(num_decorations, decorative_textures.size())
	var tries_per_decoration := 10  # Limit attempts to avoid infinite loops
	var textures = decorative_textures.duplicate()
	textures.shuffle()  # Randomize order

	for i in range(num_decorations):
		var placed := false
		var texture = textures[i]
		for x in range(tries_per_decoration):
			var candidate_position = Vector2(
				randf_range(bounds.position.x, bounds.position.x + bounds.size.x),
				randf_range(bounds.position.y, bounds.position.y + bounds.size.y)
		 )

			var too_close := false
			for pos in avoid_positions:
				if candidate_position.distance_to(pos) < avoid_radius:
					too_close = true
					break

			if too_close:
				continue

			var sprite = Sprite2D.new()
			sprite.texture = texture

			sprite.position = candidate_position
			sprite.scale *= randf_range(0.8, 1.2)
			sprite.z_index = 0
			var ran = randi_range(0, 1)
			if ran == 1:
				sprite.scale.x *= -1
			add_child(sprite)
			placed = true
			break  # Go to next decoration

		if not placed:
			print("Could not place decoration after multiple tries.")

func load_decorative_textures_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			var texture = load(folder_path + "/" + file_name)
			if texture is Texture2D:
				decorative_textures.append(texture)
			else:
				print("Skipped non-texture file:", file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

func save_map_to_state():
	var node_data_array = []
	for node in all_nodes:
		var conn_ids = []
		for conn in node.connections:
			conn_ids.append(conn.map_id)

		node_data_array.append({
			"id": node.map_id,
			"room_type": node.room_type,
			"position": node.global_position,
			"state": node.state,
			"connections": conn_ids,
			"is_connected": node.is_connected
		})
	
	MapState.nodes = node_data_array

func _on_trigger_save():
	save_map_to_state()

func switch_to_scene(scene):
	SceneManager.switch_to_scene(scene)


func _on_texture_button_pressed() -> void:
	SceneManager.switch_to_scene("res://systems/test_room.tscn")
