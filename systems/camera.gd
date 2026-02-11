extends Camera2D

@export var look_ahead_distance := 50.0   # how far ahead the camera should pan
@export var look_ahead_speed := 5.0        # how quickly the camera moves toward target

var last_player_position := Vector2.ZERO

func _ready() -> void:
	if TestPlayer:
		global_position = TestPlayer.global_position
		last_player_position = TestPlayer.global_position

func _physics_process(delta: float) -> void:
	if not TestPlayer:
		return

	# --- 1. Calculate player movement direction
	var movement := TestPlayer.global_position - last_player_position
	var look_offset := Vector2.ZERO

	if movement.length() > 1:  # threshold to ignore tiny jitter
		look_offset = movement.normalized() * look_ahead_distance

	# --- 2. Target camera position = player position + look ahead
	var target_pos := TestPlayer.global_position + look_offset

	# --- 3. Smoothly move camera toward target
	global_position = global_position.lerp(target_pos, look_ahead_speed * delta)

	# --- 4. Store player position for next frame
	last_player_position = TestPlayer.global_position

func reset_to_zero():
	global_position = Vector2.ZERO
