extends BaseEnemy

func _ready() -> void:
	attack_animation_length = 0.8666
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(min_speed, max_speed)
	base_speed = speed
	attack_speed = base_attack_speed

func _physics_process(delta: float) -> void:
	check_touch()
	get_target()

	handle_death(delta)
	damage_cooldown += delta

	if health < max_health:
		health_bar.visible = true

	# Handle post-attack delay
	if waiting_after_attack:
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			animation_player.play("move")
			post_attack_delay = 0.0

	# Move toward target if not attacking, dead, or pushed
	elif not dead and not is_pushed and not is_frozen:
		if is_instance_valid(target):
			if is_attacking:
				global_position = global_position.move_toward(target.global_position, speed * 0.75 * delta)
			else:
				global_position = global_position.move_toward(target.global_position, speed * delta)

	health_below_zero()

	attack_check()
	process_attack_check(delta)

func start_attack():
	if reached_player:
		guarantee_hit = true
	animation_player.play("attack")
	is_attacking = true
	attack_duration = 0.0

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
