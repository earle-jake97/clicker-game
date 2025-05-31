extends Node2D

@onready var boss_spawn: Marker2D = $boss_spawn

const DEVIL_BOSS = preload("res://sprites/enemies/devil_boss/devil_boss.tscn")
const EVIL_WIZARD = preload("res://sprites/enemies/evil_wizard/evil_wizard.tscn")
var boss
var can_process = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rand = randf()
	if rand <= 0.3:
		boss = DEVIL_BOSS.instantiate()
		boss.scale = Vector2(0.4, 0.4)
	else:
		boss = EVIL_WIZARD.instantiate()
	boss.global_position = boss_spawn.global_position
	boss.add_to_group("boss")
	add_child(boss)
	boss.died.connect(_on_boss_died)
	
	GameState.on_map_screen = false
	TestPlayer.visible = true
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	PlayerController.difficulty += 1
	if GameState.endless_mode:
		GameState.endless_counter += 1
	PlayerController.reset_positions()
	

func _on_boss_died():
	await get_tree().create_timer(2.0).timeout
	GameState.endless_mode = true
	HealthBar.endless_sprite.visible = true
	var rand = randf()
	queue_free()
	if rand <= 0.3:
		SceneManager.switch_to_scene("res://systems/shop/shop_endless.tscn")
	else:
		SceneManager.switch_to_scene("res://systems/shop/item_room_endless.tscn")
