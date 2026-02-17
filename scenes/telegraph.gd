extends Node2D

@export var damage: int
@export var armor_penetration: int
@export var duration: float = 1.0
var knockback_strength = 0.0
var max_scale = Vector2(1.0, 1.0)

var elapsed_time := 0.0
var targets_in_area := []

func _ready() -> void:
	scale = Vector2.ZERO  # Start at zero scale

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# Scale up smoothly to 1.0 over duration
	var t = clamp(elapsed_time / duration, 0.0, 1.0)
	scale = max_scale * t
	
	if elapsed_time >= duration:
		# Only damage the targets still in the area
		for target in targets_in_area.duplicate():
			if is_instance_valid(target) and target.has_method("take_damage"):
				target.take_damage(damage, armor_penetration)
				if is_instance_valid(target) and target.has_method("apply_knockback"):
					print("RAN")
					var direction = target.global_position - global_position
					target.apply_knockback(direction, knockback_strength)
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var node = area.get_parent()
		if node and not targets_in_area.has(node):
			targets_in_area.append(node)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var node = area.get_parent()
		targets_in_area.erase(node)
