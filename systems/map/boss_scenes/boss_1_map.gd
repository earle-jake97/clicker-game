extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.on_map_screen = false
	TestPlayer.visible = true
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	PlayerController.difficulty += 1
	if GameState.endless_mode:
		GameState.endless_counter += 1
	PlayerController.reset_positions()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	clear()

func clear():
	if get_tree().get_nodes_in_group("boss").size() < 1:
		GameState.endless_mode = true
		HealthBar.endless_sprite.visible = true
		var rand = randf()
		queue_free()
		if rand <= 0.3:
			SceneManager.switch_to_scene("res://systems/shop/shop_endless.tscn")
		else:
			SceneManager.switch_to_scene("res://systems/shop/item_room_endless.tscn")
