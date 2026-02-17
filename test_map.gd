extends Node2D

var spawners = []
const MapView = "res://map/map_scene.tscn"
const eyeball_enemy = preload("uid://b41mbcd7jm5er")
@onready var label: Label = $CanvasLayer/Label


func _ready() -> void:
	PlayerController.difficulty = 1
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	#PlayerController.movement_speed = 600
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)
	await get_tree().create_timer(0.5).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		var enemy_scene = eyeball_enemy.instantiate()
		enemy_scene.max_health = 10000
		enemy_scene.global_position = randi_range(-1000, 1000) * Vector2.ONE
		add_child(enemy_scene)
		label.text = "Enemy Count: " + str(get_tree().get_nodes_in_group("enemy").size())
		

func check_spawner_complete():
	for spawner in spawners:
		if not spawner.all_enemies_spawned:
			return
	if get_tree().get_nodes_in_group("elite").size() > 0:
		return
	SceneManager.switch_to_scene(MapView)
