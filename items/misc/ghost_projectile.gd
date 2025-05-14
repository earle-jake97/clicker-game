extends Node2D

@export var speed := 1500.0
var target_position: Vector2
var exploded := false
var player
var damage_multiplier := 3.0
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var start_y := 0.0

func _ready() -> void:
	collision_shape_2d.disabled = true
	start_y = position.y  # Store initial Y position

func _physics_process(delta: float) -> void:
	if exploded:
		return

	position.y += speed * delta

	# Calculate proximity factor (0 = far, 1 = close)
	var total_distance = target_position.y - start_y
	var remaining_distance = target_position.y - position.y
	var proximity = clamp(1.0 - (remaining_distance / total_distance), 0.0, 1.0)

	# Interpolate color from white to red
	sprite.modulate = Color(1.0, 1.0 - proximity, 1.0 - proximity)

	if position.y >= target_position.y:
		explode()

func explode():
	exploded = true
	collision_shape_2d.disabled = false

	var explosion = preload("res://items/misc/explosion.tscn").instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	await get_tree().create_timer(0.1).timeout
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.is_in_group("enemy") and enemy.has_method("take_damage"):
		var result = player.calculate_damage()
		var damage = result.damage * damage_multiplier
		enemy.take_damage(damage, result.crit)
