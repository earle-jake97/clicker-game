extends Node2D

@export var speed: float = 500.0

var direction = Vector2.ZERO
var rotation_speed := 0.0
var start_pos: Vector2
var damage: float
var crit: bool
var target_pos: Vector2
var max_lifetime = 4.0
var lifetime = 0.0
var enemy

func _ready():
	scale = GameState.get_size_modifier()
	global_position = start_pos
	rotation_speed = randf_range(40.0, 50.0)
	direction = (target_pos - start_pos).normalized()

func _process(delta):
	global_position += speed * delta * direction
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()
	rotation += deg_to_rad(10)


func _on_area_2d_area_entered(area: Area2D) -> void:
	enemy = area.get_parent()
	if enemy.has_method("take_damage") and enemy.is_in_group("enemy"):
			enemy.take_damage(round(damage), crit)
