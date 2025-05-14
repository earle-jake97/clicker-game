extends Node

var on_map_screen = true
var plague_layer = -3
var visited_nodes_map_1: = {}
var current_node_id = "node_0_0"
var current_room_type
var shopkeeper_mad = false
var leave_shop_triggered = false
var node_connections_map_1 = {
	#Layer 0
	"node_0_0": ["node_1_1"],
	
	# Layer 1
	"node_1_1": ["node_2_1", "node_2_2"],

	# Layer 2
	"node_2_1": ["node_1_1", "node_2_2", "node_3_1", "node_3_2"],
	"node_2_2": ["node_1_1", "node_2_1", "node_3_3", "node_3_4"],

	# Layer 3
	"node_3_1": ["node_2_1", "node_4_1"],
	"node_3_2": ["node_2_1", "node_4_1", "node_4_2"],
	"node_3_3": ["node_2_2", "node_4_2", "node_4_3"],
	"node_3_4": ["node_2_2", "node_4_3"],

	# Layer 4
	"node_4_1": ["node_3_1", "node_3_2", "node_5_1", "node_5_2"],
	"node_4_2": ["node_3_2", "node_3_3", "node_5_2", "node_5_3"],
	"node_4_3": ["node_3_3", "node_3_4", "node_5_3", "node_5_4"],

	# Layer 5
	"node_5_1": ["node_4_1", "node_6_1"],
	"node_5_2": ["node_4_1", "node_4_2", "node_6_1", "node_6_2"],
	"node_5_3": ["node_4_2", "node_4_3", "node_6_2", "node_6_3"],
	"node_5_4": ["node_4_3", "node_6_3"],

	# Layer 6
	"node_6_1": ["node_5_1", "node_5_2", "node_7_1"],
	"node_6_2": ["node_5_2", "node_5_3", "node_7_1", "node_7_2"],
	"node_6_3": ["node_5_3", "node_5_4", "node_7_2"],

	# Layer 7
	"node_7_1": ["node_6_1", "node_6_2", "node_8_1"],
	"node_7_2": ["node_6_2", "node_6_3", "node_8_1"],

	# Layer 8
	"node_8_1": ["node_7_1", "node_7_2"]
}
