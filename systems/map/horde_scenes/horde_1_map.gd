extends Node2D

var spawners = []
const MapView = "res://map/map_view.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.horde_bool = true
	GameState.on_map_screen = false
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	TestPlayer.visible = true
	PlayerController.reset_positions()
	PlayerController.position = 2
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)
	await get_tree().create_timer(0.5).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("enemy"):
		pass
	else:
		check_spawner_complete()

func check_spawner_complete():
	for spawner in spawners:
		if not spawner.all_enemies_spawned:
			return
	if get_tree().get_nodes_in_group("enemy").size() > 0:
		return
	TestPlayer.visible = false
	PlayerController.position = 2
	GameState.on_map_screen = true
	GameState.horde_bool = false
	SceneManager.switch_to_scene(MapView)
