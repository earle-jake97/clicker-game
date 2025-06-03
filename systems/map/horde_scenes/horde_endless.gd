extends Node2D
const ITEM_ROOM = preload("res://systems/shop/item_room_endless.tscn")
const SHOP = preload("res://systems/shop/shop_endless.tscn")
const HORDE_ENDLESS = preload("res://systems/map/horde_scenes/horde_endless.tscn")
const BOSS_ENDLESS = preload("res://systems/map/boss_scenes/boss_1_map.tscn")
@onready var background: Sprite2D = $background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.on_map_screen = false
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	TestPlayer.visible = true
	GameState.endless_counter += 1
	PlayerController.difficulty += 1
	PlayerController.reset_positions()
	var difficulty = PlayerController.difficulty
	if GameState.endless_counter >= 40:
		background.texture = preload("res://backgrounds/doom.png")
	elif GameState.endless_counter >= 25:
		background.texture = preload("res://backgrounds/despair.png")
	elif GameState.endless_counter >= 15:
		background.texture = preload("res://backgrounds/2_hell.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_level_completion()

func check_level_completion():
	var room
	if get_tree().get_nodes_in_group("spawner"):
		for spawner in get_tree().get_nodes_in_group("spawner"):
			if spawner.check_level_finished():
				pass
			else:
				return false
		if get_tree().get_nodes_in_group("enemy"):
			return false
		var rand = randf()
		if rand <= 0.2:
			print("going to shop")
			SceneManager.switch_to_scene("res://systems/shop/shop_endless.tscn")
		elif rand <= 0.75:
			print("going to item")
			SceneManager.switch_to_scene("res://systems/shop/item_room_endless.tscn")
		else:
			print("going to horde")
			SceneManager.switch_to_scene("res://horde_transition_fix.tscn")
