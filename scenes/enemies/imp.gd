extends BaseEnemy

func extra_ready():
	base_speed = 140.0
	base_attack_speed = 0.8
	damage = 10
	max_health = 130.0
	attack_animation_length = 0.8666

func extra_processing(delta):
	if waiting_after_attack:
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			animation_player.play("move")
			post_attack_delay = 0.0

func move_towards_target(delta):
	if not can_move or unique_movement or spawning:
		return
	# Move toward player only if not waiting after attack
	if player and not is_attacking and post_attack_delay <= 0.01 and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 40.0:
		global_position = global_position.move_toward(target.global_position, speed * delta)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = true
		guarantee_hit = true
		touching_entity = area.get_parent()

	elif area.is_in_group("minion_hitbox"):
		touching_player = false
		touching_entity = area.get_parent()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if touching_entity and area.get_parent() == touching_entity:
		touching_entity = null
		touching_player = false
