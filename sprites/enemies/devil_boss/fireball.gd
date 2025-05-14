extends Node2D

var start_pos: Vector2
var target_pos: Vector2
var flight_time := 1.5
var timer := 0.0
var velocity: Vector2
var player = PlayerController

func _ready():
	global_position = start_pos
	# Calculate velocity needed to reach the target in 1.5 seconds
	velocity = (target_pos - start_pos) / flight_time

func _physics_process(delta):
	rotation += deg_to_rad(30)
	timer += delta
	global_position += velocity * delta

	if timer >= flight_time:
		explode()

func explode():
	# (You can play an animation or damage here)
	queue_free()
