# res://scripts/map/map_generator.gd
extends Node

const ROOM_TYPES = ["horde", "shop", "item", "miniboss", "gamble", "heart", "boss", "time"]

func get_rooms_in_layer(layer: int) -> int:
	var layout = {1: 1, 2: 2, 3: 4, 4: 3, 5: 4, 6: 3, 7: 2, 8: 1}
	return layout.get(layer, 1)

func pick_room_type(layer: int, index: int, map: Resource) -> String:
	if layer == 8:
		return "boss"
	if layer == 1:
		return "start"
	if layer == 2 and index == 0:
		return "shop"
	return "horde"

func connect_rooms(map: Resource, rng: RandomNumberGenerator) -> void:
	for layer in range(1, 8):
		var current_layer = map.layers[layer]
		var next_layer = map.layers[layer + 1]
		for room in current_layer:
			var num_connections = rng.randi_range(1, 2)
			for _i in range(num_connections):
				var target = next_layer[rng.randi_range(0, next_layer.size() - 1)]
				if target.id not in room.connected_ids:
					room.connected_ids.append(target.id)


func generate_map(seed: int = -1):
	var rng := RandomNumberGenerator.new()
	if seed != -1:
		rng.seed = seed
	else:
		rng.randomize()

	var map := MapData.new()
	for layer in range(1, 9):
		var rooms: Array = []
		var count = get_rooms_in_layer(layer)
		for i in range(count):
			var room = MapData.RoomData.new()
			room.id = "L%d_R%d" % [layer, i]
			room.layer = layer
			room.room_type = pick_room_type(layer, i, map)
			rooms.append(room)
		map.layers[layer] = rooms

	connect_rooms(map, rng)
	return map
