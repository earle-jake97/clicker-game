extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
var spawners = []
const MapView = "res://map/map_scene.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_2d.reset_to_zero()
	GameState.horde_bool = true
	GameState.enemy_count = 0
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)
	for spawner in spawners:
		GameState.enemy_count += spawner.get_spawn_cap()
	await get_tree().create_timer(0.5).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if EnemyManager.get_all_enemies():
		pass
	else:
		check_spawner_complete()

func check_spawner_complete():
	for spawner in spawners:
		if not spawner.all_enemies_spawned:
			return
	if EnemyManager.get_all_enemies().size() > 0:
		return
	GameState.enemy_count = 0
	GameState.horde_bool = false
	SceneManager.switch_to_scene(MapView)
