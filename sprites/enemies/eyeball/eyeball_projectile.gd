extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var target = PlayerController.player

@export var speed: float = 400.0
@export var turn_speed: float = 2 # radians per second (lower = wider turns)
@export var lifetime: float = 4.5
var timer = 0.0

var velocity: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Start moving in the facing direction
	if is_instance_valid(target):
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * speed
		rotation = dir.angle() + PI
	else:
		velocity = Vector2.RIGHT * speed

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifetime:
		destroy_projectile()
	# === TARGET SELECTION (unchanged logic) ===
	for entity in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(entity):
			continue

		var distance = global_position.distance_to(entity.global_position)

		var is_closer = true
		if is_instance_valid(target):
			is_closer = distance < global_position.distance_to(target.global_position)

		if entity.has_method("is_alive") and entity.is_alive() and is_closer and entity.global_position.x <= global_position.x:
			if is_instance_valid(target) and entity.find_child("pivot", 1, 1):
				target = entity.find_child("pivot", 1, 1)
			else:
				target = entity
		else:
			target = PlayerController.player.find_child("pivot", 1, 1)

	# === STEERING LOGIC ===
	if is_instance_valid(target):
		var desired_direction = (target.global_position - global_position).normalized()
		var current_direction = velocity.normalized()

		# Gradually rotate toward target direction
		var new_direction = current_direction.slerp(desired_direction, turn_speed * delta)
		velocity = new_direction * speed

	# === MOVE ===
	global_position += velocity * delta

	# === VISUAL ROTATION ===
	rotation = velocity.angle() + PI

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var this_target = area.get_parent()
		if this_target.has_method("take_damage"):
			var direction = this_target.global_position - global_position
			var knockback_parameters = [direction, 200, false]
			this_target.take_damage(1, 0, false, knockback_parameters)
		queue_free()

func destroy_projectile():
	queue_free()
