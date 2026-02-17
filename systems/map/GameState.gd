extends Node

var plague_layer = -3
var visited_nodes_map_1: = {}
var current_node_id = "node_0_0"
var current_room_type
var shopkeeper_mad = false
var endless_mode = false
var endless_counter = 0
var current_world = 1
var last_background 
var scythe_amount = 0
var on_start_screen = false
var enemy_count = 0
var horde_bool = false

func get_size_modifier():
	var size = Vector2(1.0, 1.0)
	for item in PlayerController.inventory:
		if item.item_name == "Sus Shroom":
			size += Vector2(0.1, 0.1)
	return size

func reset_all():
	plague_layer = -3
	visited_nodes_map_1 = {}
	current_node_id = "node_0_0"
	current_room_type
	shopkeeper_mad = false
	endless_mode = false
	endless_counter = 0
	current_world = 1
	last_background 
	scythe_amount = 0
	horde_bool = false
	enemy_count = 0
