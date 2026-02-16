extends Node2D

@export var lifetime := 0.8
@export var fade_time := 0.8
var random_vec
var random_speed
const SPREAD_SPEED = 400

func _ready():
	# Randomize scale and direction
	random_vec = Vector2(randf_range(0.8, 1.0), randf_range(0.0, -1.0)).normalized()
	random_speed = randf_range(230, SPREAD_SPEED)
	rotation = randf_range(0, TAU)
	position += Vector2(randf_range(-10, 10), randf_range(-10, 10))

	# Fade out and queue free
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	global_position += random_vec * random_speed * delta
	rotation += rad_to_deg(15)
