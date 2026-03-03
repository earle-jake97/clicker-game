extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
const MapView = "res://map/map_scene.tscn"
@onready var label: Label = $CanvasLayer/Label
@onready var timer: Timer = $Timer
@onready var exit: Button = $CanvasLayer/Exit
var room_cleared = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_2d.reset_to_zero()
	if not GameState.timed_room:
		GameState.horde_bool = true
	GameState.enemy_count = 0
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	
	if GameState.timed_room:
		label.visible = true
		timer.start()
		
	await get_tree().create_timer(0.5).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "%10.f" % timer.time_left
	if not GameState.timed_room and not room_cleared:
		if EnemyManager.get_all_enemies():
			pass
		else:
			check_room_complete()

func check_room_complete():
	if EnemyManager.get_all_enemies().size() > 0:
		return
	GameState.enemy_count = 0
	GameState.horde_bool = false
	EnemyManager.signal_magnet()
	exit.show()
	
func _on_timer_timeout() -> void:
	EnemyManager.kill_all_enemies_in_list()
	EnemyManager.signal_magnet()
	exit.show()
	room_cleared = true

func _on_exit_pressed() -> void:
	GameState.timed_room = false
	SceneManager.switch_to_scene("res://map/map_scene.tscn")
