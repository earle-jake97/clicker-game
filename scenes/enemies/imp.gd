extends BaseEnemy

func extra_ready():
	attack_animation_length = 0.8666

func extra_processing(delta):
	if waiting_after_attack:
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			animation_player.play("move")
			post_attack_delay = 0.0
	elif not dead and not is_pushed and not is_frozen:
		if is_instance_valid(target):
			if is_attacking:
				global_position = global_position.move_toward(target.global_position, speed * 0.75 * delta)
			else:
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
