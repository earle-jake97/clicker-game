extends Node2D

var spawners = []
const MapView = "res://map/map_scene.tscn"
@onready var label: Label = $CanvasLayer/Label
@onready var timer: Timer = $Timer


func _ready() -> void:
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "%10.f" % timer.time_left

func _on_timer_timeout() -> void:
	SceneManager.switch_to_scene(MapView)
