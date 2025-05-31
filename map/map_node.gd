extends Node2D
@onready var map_node: Node2D = $"."

signal trigger_save

@onready var cleared_marker: Sprite2D = $ClearedMarker
enum NodeState { UNVISITED, CONNECTED, CLEARED }
@export var room_type: String = "horde"
var state: NodeState = NodeState.UNVISITED
var connections = []
@onready var sprite: Sprite2D = $Sprite2D
var node_hovered = false
var is_connected = false
const BOSS = preload("res://map/boss.png")
const EVENT = preload("res://map/event.png")
const HORDE = preload("res://map/horde.png")
const ITEM = preload("res://map/item.png")
const MINIBOSS = preload("res://map/miniboss.png")
const SHOP = preload("res://map/shop.png")
const START = preload("res://map/start.png")
const TIME = preload("res://map/time.png")
var map_id
signal switch_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_sprite()
	if state == NodeState.CLEARED:
		cleared_marker.visible = true
	else:
		cleared_marker.visible = false

func set_state(new_state):
	state = new_state
	
	match state:
		NodeState.CLEARED:
			cleared_marker.visible = true
		NodeState.CONNECTED:
			modulate = Color(1, 1, 1) # full brightness
		NodeState.UNVISITED:
			modulate = Color(0.5, 0.5, 0.5)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and node_hovered and is_connected and state != NodeState.CLEARED:
		set_cleared()
		trigger_save.emit()
		go_to_map(room_type)

func _on_area_2d_mouse_entered() -> void:
	node_hovered = true

func _on_area_2d_mouse_exited() -> void:
	node_hovered = false

func set_cleared():
	if state == NodeState.CLEARED:
		return
	else:
		set_state(NodeState.CLEARED)
		for node in connections:
			node.is_connected = true

func set_sprite():
	match room_type:
		"horde":
			sprite.texture = HORDE
		"boss":
			sprite.texture = BOSS
		"time":
			sprite.texture = TIME
		"shop":
			sprite.texture = SHOP
		"item":
			sprite.texture = ITEM
		"miniboss":
			sprite.texture = MINIBOSS
		"horde":
			sprite.texture = HORDE
		"event":
			sprite.texture = EVENT
		_:
			sprite.texture = START

func go_to_map(type):
	if type == "horde":
		PlayerController.difficulty += 1
		TestPlayer.visible = true
		PlayerController.position = 2
		GameState.on_map_screen = false
		SceneManager.switch_to_scene("res://systems/map/horde_scenes/horde_1_map.tscn")
	elif type == "miniboss":
		PlayerController.difficulty += 1
		TestPlayer.visible = true
		PlayerController.position = 2
		SceneManager.switch_to_scene("res://world1/miniboss_1.tscn")
	elif type == "shop":
		SceneManager.switch_to_scene("res://systems/shop/shop_endless.tscn")
	elif type == "item":
		SceneManager.switch_to_scene("res://systems/shop/item_room.tscn")
	elif type == "boss":
		PlayerController.difficulty += 1
		TestPlayer.visible = true
		PlayerController.position = 2
		SceneManager.switch_to_scene("res://systems/map/boss_scenes/boss_1_map.tscn")
	elif type == "start":
		SceneManager.switch_to_scene("res://systems/starter_room.tscn")
		GameState.on_map_screen = false
	elif type == "time":
		SceneManager.switch_to_scene("res://systems/map/horde_scenes/horde_timer.tscn")
		GameState.on_map_screen = false
	elif type == "event":
		var rande = randf()
		if rande <= 0.5:
			SceneManager.switch_to_scene("res://systems/shop/secret_shop.tscn")
		else:
			SceneManager.switch_to_scene("res://systems/map/horde_scenes/tank_devil_map.tscn")
	
		
