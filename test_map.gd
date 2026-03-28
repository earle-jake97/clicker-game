extends Node2D

var spawners = []
const MapView = "res://map/map_scene.tscn"
const devil_enemy = preload("uid://ducyvw4p4i56c")
@onready var label: Label = $CanvasLayer/Label
const EYEBALL_ENEMY = preload("uid://t8ttvohfehwf")
const IMP = preload("uid://b43cnfq107mjk")


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
	SceneManager.switch_to_scene(MapView)
