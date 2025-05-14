extends Area2D

var start_pos: Vector2
var target_pos: Vector2
var flight_time := 1.0
var timer := 0.0
var arc_height := 400.0  # how high the arc goes
var chosen_area
var player = PlayerController

func _ready():
	global_position = start_pos

func _physics_process(delta):
	timer += delta
	var t = timer / flight_time
	t = clamp(t, 0.0, 1.0)

	# Linear interpolation
	var linear_pos = start_pos.lerp(target_pos, t)

	# Arc offset (move up and then down)
	var height = arc_height * 4 * t * (1.0 - t)  # Peaks at t=0.5
	var arc_pos = linear_pos - Vector2(0, height)

	global_position = arc_pos

	if timer >= flight_time:
		explode()

func explode():
	# (You can play an animation or damage here)
	queue_free()
