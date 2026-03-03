extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var active = false
var check_time = 0.0
var check_interval = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SpawnManager.init_spawner(self)
	sprite_2d.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_time += delta
	if check_interval <= check_time:
		check_time = 0.0
		if calculate_player_distance():
			SpawnManager.add_spawner(self)
		else:
			SpawnManager.remove_spawner(self)

func calculate_player_distance() -> bool:
	if is_instance_valid(PlayerController.get_player_body()):
		var distance_to_player = global_position.distance_to(PlayerController.get_player_body().global_position)
		if distance_to_player >= 1500.0:
			return true
	return false

func clear():
	queue_free()

func is_active():
	return active

func spawn_enemy():
	return
