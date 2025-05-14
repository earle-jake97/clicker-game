extends Node2D

@export var lifetime := 1.5
@export var fade_time := 1.0
var random_vec
var random_speed
const SPREAD_SPEED = 100
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Randomize scale and direction
	random_vec = Vector2(randf_range(-1.0, 1.0), randf_range(-0.2, 0.2)).normalized()
	random_speed = randf_range(50, SPREAD_SPEED)
	scale = Vector2.ONE * randf_range(0.5, 1.5)
	rotation = randf_range(0, TAU)
	position += Vector2(randf_range(-10, 10), randf_range(-10, 10))
	z_index = global_position.y

	# Fade out and queue free
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	global_position += random_vec * random_speed * delta
	z_index = global_position.y + 6
