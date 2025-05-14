extends Node2D

var shop_2_present = false
var shop_3_present = false
var miniboss_2_present = false
var gamble_2_present = false
var shop_4_present = false  
var item_5_present = false
var gamble_5_present = false
var shop_7_present = false
var heart_7_present = false
var time_present = false

const COMPLETED_OVERLAY = preload("res://sprites/test_player/completed.png")
const SHOP_NODE = preload("res://sprites/test_player/shop_node.png")
const MINIBOSS_NODE = preload("res://sprites/test_player/miniboss_node.png")
const ITEM_NODE = preload("res://sprites/test_player/item_node.png")
const HORDE_NODE = preload("res://sprites/test_player/horde_node.png")
const GAMBLE_NODE = preload("res://sprites/test_player/gamble_node.png")
const BOSS_NODE = preload("res://sprites/test_player/boss_node.png")
const HEART_NODE = preload("res://sprites/test_player/heart_node.png")
const HORDE_CHALLENGE_NODE = preload("res://sprites/test_player/horde_challenge.png")
const TIME_NODE = preload("res://sprites/test_player/time_node.png")

func _ready() -> void:
	generate_layer()

func generate_layer() -> void:
	var tree = get_tree().get_nodes_in_group("layer")
	for layer in tree:
		var room_list = layer.get_children()
		if "layer_1" in layer.name:
			generate_layer_1(room_list)
		if "layer_2" in layer.name:
			generate_layer_2(room_list)
		elif "layer_3" in layer.name:
			generate_layer_3(room_list)
		elif "layer_4" in layer.name:
			generate_layer_4(room_list)
		elif "layer_5" in layer.name:
			generate_layer_5(room_list)
		elif "layer_6" in layer.name:
			generate_layer_6(room_list)
		elif "layer_7" in layer.name:
			generate_layer_7(room_list)
		elif "layer_8" in layer.name:
			generate_layer_8(room_list)

func generate_layer_1(room_list: Array) -> void:
	for room in room_list:
		change_sprite(room, "horde", HORDE_NODE)


# Layer 2 – Loot Rooms (1 Shop + 1 Item)
func generate_layer_2(room_list: Array) -> void:
	for i in range(room_list.size()):
		var room = room_list[i]
		if i == 0:
			var rand = randi_range(1, 2)
			if rand == 1:
				shop_2_present = true
				change_sprite(room, "shop", SHOP_NODE)
			else:
				change_sprite(room, "item", ITEM_NODE)
		else:
			if shop_2_present:
				change_sprite(room, "item", ITEM_NODE)
			else:
				change_sprite(room, "shop", SHOP_NODE)

# Layer 3 – Mostly Horde, possible Miniboss or Gamble
func generate_layer_3(room_list: Array) -> void:
	for room in room_list:
		var roll = randf()
		if roll <= 0.15 and not miniboss_2_present:
			miniboss_2_present = true
			change_sprite(room, "miniboss", MINIBOSS_NODE)
		elif roll <= 0.30 and not gamble_2_present:
			gamble_2_present = true
			change_sprite(room, "gamble", GAMBLE_NODE)
		elif roll <= 0.35 and not time_present:
			time_present = true
			change_sprite(room, "time", TIME_NODE)
		else:
			change_sprite(room, "horde", HORDE_NODE)

# Layer 4 – 1 Item room, chance for 1 Shop
func generate_layer_4(room_list: Array) -> void:
	shop_4_present = false
	var item_index = randi_range(0, room_list.size() - 1)
	for i in range(room_list.size()):
		var room = room_list[i]
		if i == item_index:
			change_sprite(room, "item", ITEM_NODE)
		else:
			var roll = randf()
			if roll <= 0.10 and not shop_4_present:
				shop_4_present = true
				change_sprite(room, "shop", SHOP_NODE)
			else:
				change_sprite(room, "horde", HORDE_NODE)

# Layer 5 – 75% Horde, 5% each for Miniboss, Item, Gamble (only 1 item/gamble allowed)
func generate_layer_5(room_list: Array) -> void:
	item_5_present = false
	gamble_5_present = false
	for room in room_list:
		var roll = randf()
		if roll <= 0.05 and not item_5_present:
			item_5_present = true
			change_sprite(room, "item", ITEM_NODE)
		elif roll <= 0.10 and not gamble_5_present:
			gamble_5_present = true
			change_sprite(room, "gamble", GAMBLE_NODE)
		elif roll <= 0.15:
			change_sprite(room, "miniboss", MINIBOSS_NODE)
		elif roll <= 0.2 and not time_present:
			time_present = true
			change_sprite(room, "time", TIME_NODE)
		else:
			change_sprite(room, "horde", HORDE_NODE)

# Layer 6 – Horde + rare Miniboss or Horde Challenge
func generate_layer_6(room_list: Array) -> void:
	for room in room_list:
		var roll = randf()
		if roll <= 0.05:
			change_sprite(room, "miniboss", MINIBOSS_NODE)
		elif roll <= 0.10:
			change_sprite(room, "horde_challenge", HORDE_CHALLENGE_NODE)
		elif roll <= 0.3 and not time_present:
			time_present = true
			change_sprite(room, "time", TIME_NODE)
		else:
			change_sprite(room, "horde", HORDE_NODE)

# Layer 7 – 5% Shop, 5% Heart (only one each), otherwise Horde
func generate_layer_7(room_list: Array) -> void:
	shop_7_present = false
	var shop_index = randi_range(0, room_list.size() - 1)
	for i in range(room_list.size()):
		var room = room_list[i]
		if i == shop_index:
			change_sprite(room, "shop", SHOP_NODE)
		else:
			var roll = randf()
			if roll <= 0.10 and not shop_7_present:
				heart_7_present = true
				change_sprite(room, "heart", HEART_NODE)
			elif roll <= 0.20 and not time_present:
				change_sprite(room, "time", TIME_NODE)
			else:
				change_sprite(room, "horde", HORDE_NODE)

func generate_layer_8(room_list: Array) -> void:
	for room in room_list:
			change_sprite(room, "boss", BOSS_NODE)

# Utility
func change_sprite(node, room_type, resource) -> void:
	if node is Sprite2D:
		print("making " + node.name + " a " + room_type)
		node.texture = resource
		node.set_meta("room_type", room_type)

func highlight_first_node() -> void:
	var all_nodes = get_tree().get_nodes_in_group("room_node")
	for node in all_nodes:
		if node.name == GameState.current_node_id:
			node.modulate = Color(1, 0.6, 0.6) # Light red tint
		else:
			node.modulate = Color(1, 1, 1) # Normal color
