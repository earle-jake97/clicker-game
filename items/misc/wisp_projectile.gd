extends Node2D
var speed = 1200
var timer = 0.0
var initial_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = 0.0
	global_position = initial_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position.move_toward(Vector2(40000, global_position.y), speed * delta)
	timer += delta
	if timer >= 4.0:
		queue_free()
