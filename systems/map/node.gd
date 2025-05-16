extends Area2D

@onready var marker: Sprite2D = $"../marker"

const ITEM_ROOM_SCENE = preload("res://systems/shop/item_room.tscn")
const SHOP_SCENE = preload("res://systems/shop/shop.tscn")
const HordeRoomScene = preload("res://systems/map/horde_scenes/horde_1_map.tscn")
const EmptyRoomScene = preload("res://systems/map/empty.tscn")
const BOSS_SCENE = preload("res://systems/map/boss_scenes/boss_1_map.tscn")
var map_scene
var parent: Node = null
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("map_root"):
		map_scene = node
	input_pickable = true
	parent = get_parent()

func _process(delta: float) -> void:
	if not GameState.endless_mode:
		check_alive_enemies()
		leave_shop()


func _input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		select_node()

func select_node() -> void:
	if parent and parent.has_meta("room_type"):
		var room_type = parent.get_meta("room_type")
		var node_id = parent.name
		var connected_nodes = GameState.node_connections_map_1.get(GameState.current_node_id, [])

		if node_id in connected_nodes:
			GameState.current_node_id = node_id
			highlight_current_node()
			marker.visible = true

			if node_id in GameState.visited_nodes_map_1:
				print("Cleared room.")
			else:
				GameState.visited_nodes_map_1[node_id] = true
				GameState.current_room_type = room_type
				GameState.plague_layer += 1
				
				match room_type:
					"horde":
						go_to_horde_room()
					"shop":
						go_to_shop()
					"item":
						go_to_item_room()
					"boss":
						go_to_boss_room()
					_:
						print("Unhandled room type: ", room_type)

func highlight_current_node() -> void:
	# Loop through all Sprite2D nodes in the map and reset modulate
	var all_nodes = get_tree().get_nodes_in_group("layer")
	for layer in all_nodes:
		for node in layer.get_children():
			if node is Sprite2D:
				node.modulate = Color(1, 1, 1) # Reset

	# Apply highlight to the new current node
	if parent and parent is Sprite2D:
		parent.modulate = Color(1.0, 0.6, 0.6) # Light red

func go_to_horde_room():
	PlayerController.difficulty += 1
	var horde_room = HordeRoomScene.instantiate()
	get_tree().root.add_child(horde_room)
	get_tree().current_scene = horde_room
	map_scene.visible = false
	PlayerController.reset_positions()
	TestPlayer.visible = true
	PlayerController.position = 2
	GameState.on_map_screen = false
	
func go_to_boss_room():
	PlayerController.difficulty += 1
	var boss_room = BOSS_SCENE.instantiate()
	get_tree().root.add_child(boss_room)
	get_tree().current_scene = boss_room
	map_scene.visible = false
	PlayerController.reset_positions()
	TestPlayer.visible = true
	PlayerController.position = 2
	GameState.on_map_screen = false

func go_to_shop():
	TestPlayer.visible = false
	var shop = SHOP_SCENE.instantiate()
	get_tree().root.add_child(shop)
	get_tree().current_scene = shop
	map_scene.visible = false
	PlayerController.reset_positions()
	GameState.on_map_screen = false

func go_to_item_room():
	TestPlayer.visible = false
	var shop = ITEM_ROOM_SCENE.instantiate()
	get_tree().root.add_child(shop)
	get_tree().current_scene = shop
	map_scene.visible = false
	PlayerController.reset_positions()
	GameState.on_map_screen = false


func check_alive_enemies():
	if get_tree().get_nodes_in_group("enemy").size() <= 0:
		return check_level_completion()

func leave_shop():
	if GameState.leave_shop_triggered:
		var empty_room = EmptyRoomScene.instantiate()
		if get_tree().current_scene:
			GameState.on_map_screen = true
			get_tree().current_scene.queue_free()
		get_tree().root.add_child(empty_room)
		get_tree().current_scene = empty_room
		TestPlayer.visible = false
		map_scene.visible = true
		GameState.leave_shop_triggered = false
		return true

		

func check_level_completion():
	if get_tree().get_nodes_in_group("spawner"):
		for spawner in get_tree().get_nodes_in_group("spawner"):
			if spawner.check_level_finished():
				pass
			else:
				return false
		var empty_room = EmptyRoomScene.instantiate()
		if get_tree().current_scene:
			GameState.on_map_screen = true
			get_tree().current_scene.queue_free()
		get_tree().root.add_child(empty_room)
		get_tree().current_scene = empty_room
		TestPlayer.visible = false
		map_scene.visible = true
		return true

func go_to_map():
	var empty_room = EmptyRoomScene.instantiate()
	if get_tree().current_scene:
		GameState.on_map_screen = true
		get_tree().current_scene.queue_free()
	get_tree().root.add_child(empty_room)
	get_tree().current_scene = empty_room
	TestPlayer.visible = false
	map_scene.visible = true
	return true
