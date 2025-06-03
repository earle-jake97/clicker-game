extends Node2D

var rotation_speed
var timer = 0.0
@onready var sprite_2d: Sprite2D = $Sprite2D
const MONEY = preload("res://systems/money.png")
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	rotation_speed = randf_range(0, 3.0)
	if randf() < 0.5:
		sprite_2d.texture = MONEY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(rotation_speed * delta)
	global_position = global_position + direction * 500 * delta
	timer += delta
	if timer >= 0.5:
		queue_free()
