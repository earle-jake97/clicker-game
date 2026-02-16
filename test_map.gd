extends Node2D

var spawners = []
const MapView = "res://map/map_scene.tscn"
# Called when the node enters the scene tree for the first time.
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
	pass

func check_spawner_complete():
	for spawner in spawners:
		if not spawner.all_enemies_spawned:
			return
	if get_tree().get_nodes_in_group("elite").size() > 0:
		return
	GameState.on_map_screen = true
	SceneManager.switch_to_scene(MapView)
