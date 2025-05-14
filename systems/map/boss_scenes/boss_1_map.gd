extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerController.reset_positions()
	TestPlayer.visible = true
	if GameState.endless_mode:
		PlayerController.difficulty += 1
		GameState.endless_counter += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	clear()

func clear():
	if get_tree().get_nodes_in_group("boss").size() < 1:
		GameState.endless_mode = true
		HealthBar.endless_sprite.visible = true
		GameState.endless_counter += 1
		var rand = randf()
		var room
		if rand <= 0.8:
			room = preload("res://systems/shop/item_room_endless.tscn").instantiate()
		else:
			room = preload("res://systems/shop/shop_endless.tscn").instantiate()
		get_tree().root.add_child(room)
		get_tree().current_scene = room
		queue_free()
