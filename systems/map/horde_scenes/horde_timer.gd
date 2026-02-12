extends Node2D

var spawners = []
const MapView = "res://map/map_scene.tscn"
@onready var timer: Timer = $Timer
@onready var label: Label = $Label
@onready var marker_2d: Marker2D = $Positions/Marker2D

func _ready() -> void:
	TestPlayer.global_position = marker_2d.global_position
	GameState.on_map_screen = false
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	TestPlayer.visible = true
	for spawner in get_tree().get_nodes_in_group("spawner"):
		spawners.append(spawner)
	await get_tree().create_timer(0.5).timeout
	timer.timeout.connect(_on_timer_timout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "%10.f" % timer.time_left

func _on_timer_timout():
	TestPlayer.visible = false
	GameState.on_map_screen = true
	SceneManager.switch_to_scene(MapView)
