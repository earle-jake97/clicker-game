extends BaseEnemy

@onready var attack_hitbox: Area2D = $container/Attack_Hitbox

func configure_enemy() -> void:
	animation_player.animation_set_next("spawn", "walk")

	base_max_health = 130.0
	base_move_speed = 140.0
	base_damage = 10
	base_attack_cooldown = 0.8
	base_knockback_strength = 300.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

	if is_instance_valid(attack_hitbox):
		attack_hitbox.monitoring = false

func should_enter_moving_state() -> bool:
	if dead or spawning:
		return false

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.SPECIAL or current_state == EnemyState.STUNNED:
		return false

	if not is_instance_valid(target):
		return false

	if should_start_attack():
		return false

	return true

func should_start_attack() -> bool:
	if dead or spawning:
		return false

	if not can_attack():
		return false

	if not is_instance_valid(touching_entity):
		return false

	return true

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			play_walk_animation()

		EnemyState.MOVING:
			play_walk_animation()

		EnemyState.ATTACKING:
			begin_attack_state()

		EnemyState.STUNNED:
			if animation_player.has_animation("walk"):
				animation_player.stop()

		EnemyState.DEAD:
			pass

func exit_state(_old_state: EnemyState) -> void:
	pass

func state_idle(_delta: float) -> void:
	if should_start_attack():
		set_state(EnemyState.ATTACKING)
		return

	if should_enter_moving_state():
		set_state(EnemyState.MOVING)

func state_moving(delta: float) -> void:
	if should_start_attack():
		set_state(EnemyState.ATTACKING)
		return

	if not is_instance_valid(target):
		set_state(EnemyState.IDLE)
		return

	move_directly_toward_target(delta, 40.0)

func state_attacking(_delta: float) -> void:
	pass

func enemy_process(_delta: float) -> void:
	pass

func animation_attack_hit() -> void:
	if dead or current_state != EnemyState.ATTACKING:
		return

	if not is_instance_valid(attack_hitbox):
		return

	var hit_areas: Array[Area2D] = attack_hitbox.get_overlapping_areas()

	var hit_targets: Array[Node] = []

	for area in hit_areas:
		if not is_instance_valid(area):
			continue

		var hit_target := area.get_parent()

		if not is_instance_valid(hit_target):
			continue

		if hit_targets.has(hit_target):
			continue

		if hit_target.has_method("take_damage"):
			hit_targets.append(hit_target)

	for hit_target in hit_targets:
		var knock_direction = hit_target.global_position - global_position
		var knockback_params = [knock_direction, knockback_strength, trigger_knockback]
		hit_target.take_damage(damage, armor_penetration, true, knockback_params)

	attack_hit.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:
	touching_entity = area.get_parent()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if touching_entity and area.get_parent() == touching_entity:
		touching_entity = null
