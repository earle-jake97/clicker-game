# MapState.gd
extends Node

var test = "blah"

var nodes = []  # Will hold dictionaries like the example above
var current_node_id: int = -1

func save_node_data(node):
	nodes.append({
		"id": node.id,
		"type": node.type,
		"position": node.position,
		"state": node.state,
		"connected_ids": node.connected_ids,
		"is_connected": node.is_connected,
		"sprite": node.sprite,
		"connections": node.connections
	})

func get_node_data_by_id(id: int) -> Dictionary:
	for node_data in nodes:
		if node_data["id"] == id:
			return node_data
	return {}

func reset_map():
	nodes = []
	current_node_id = -1
