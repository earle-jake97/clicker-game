extends Camera2D

@export var look_ahead_distance := 50.0   # how far ahead the camera should pan
@export var look_ahead_speed := 5.0        # how quickly the camera moves toward target
var last_player_position := Vector2.ZERO
var pc = PlayerController
var player = null

func _ready() -> void:
	if pc.get_player_body():
		player = pc.get_player_body()
		global_position = player.global_position
		last_player_position = player.global_position

func _physics_process(delta: float) -> void:
	if player == null:
		player = pc.get_player_body()
		return

	# --- 1. Calculate player movement direction
	var movement = player.global_position - last_player_position
	var look_offset := Vector2.ZERO

	if movement.length() > 1:  # threshold to ignore tiny jitter
		look_offset = movement.normalized() * look_ahead_distance

	# --- 2. Target camera position = player position + look ahead
	var target_pos = player.global_position + look_offset

	# --- 3. Smoothly move camera toward target
	global_position = global_position.lerp(target_pos, look_ahead_speed * delta)

	# --- 4. Store player position for next frame
	last_player_position = player.global_position

func reset_to_zero():
	global_position = Vector2.ZERO
