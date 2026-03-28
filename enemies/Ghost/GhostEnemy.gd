extends BaseEnemy

var has_hidden := false
var hiding := false
var hide_timer := 0.0
var hide_duration := 2.0
var health_snapshot := 0.0

@onready var attack_hitbox: Area2D = $container/Attack_Hitbox
@onready var body: AnimatedSprite2D = $container/sprite/body
@onready var timer: Timer = $Timer

func configure_enemy() -> void:
	animation_player.animation_set_next("spawn", "walk")

	base_max_health = 250.0
	base_move_speed = 80.0
	base_damage = 10
	base_knockback_strength = 700.0
	base_attack_cooldown = 0.35
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

	if is_instance_valid(attack_hitbox):
		attack_hitbox.monitoring = false

func should_enter_moving_state() -> bool:
	if dead or spawning or hiding:
		return false

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.SPECIAL or current_state == EnemyState.STUNNED:
		return false

	if not is_instance_valid(target):
		return false

	if should_start_attack():
		return false

	return true

func should_start_attack() -> bool:
	if dead or spawning or hiding:
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

		EnemyState.SPECIAL:
			if animation_player.has_animation("hide"):
				animation_player.play("hide")

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

	move_directly_toward_target(delta, 10.0)

func state_attacking(_delta: float) -> void:
	pass

func state_special(_delta: float) -> void:
	pass

func enemy_process(delta: float) -> void:
	if hiding:
		hide_timer += delta

	if health <= max_health / 2.0 and not has_hidden:
		start_hide()

	if hiding and hide_timer < hide_duration:
		attack_cooldown_timer = 0.0

		var t := hide_timer / hide_duration
		t = clampf(t, 0.0, 1.0)

		health = lerpf(health_snapshot, max_health, t)

		if health_bar:
			health_bar.value = health

func start_hide() -> void:
	if has_hidden:
		return

	has_hidden = true
	hiding = true
	hide_timer = 0.0
	health_snapshot = health

	invulnerable = true
	targetable = false
	can_move = false
	touching_entity = null
	touching_player = false

	set_state(EnemyState.SPECIAL)

	EnemyManager.unregister(self)
	remove_from_group("enemy")

	if is_instance_valid(timer):
		timer.start(hide_duration)

	if is_instance_valid(body) and body.sprite_frames and body.sprite_frames.has_animation("hide"):
		body.play("hide")

	if is_instance_valid(animation_player) and animation_player.has_animation("hide"):
		animation_player.play("hide")

func finish_hide() -> void:
	hiding = false
	health = max_health

	if health_bar:
		health_bar.value = health

	invulnerable = false
	targetable = true
	can_move = true

	EnemyManager.register(self)
	add_to_group("enemy")

	if is_instance_valid(body) and body.sprite_frames and body.sprite_frames.has_animation("idle"):
		body.play("idle")

	set_state(EnemyState.IDLE)

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

func _on_timer_timeout() -> void:
	finish_hide()
