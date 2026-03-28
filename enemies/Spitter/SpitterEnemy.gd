extends BaseEnemy

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_hitbox: Area2D = $container/Attack_Hitbox

@export var projectile_scene: PackedScene = preload("res://scenes/mad projectile.tscn")
@export var telegraph_scene: PackedScene = preload("res://scenes/telegraph.tscn")

@export var projectile_damage: int = 20
@export var projectile_knockback_strength: float = 700.0
@export var shot_precision: float = 100.0

@export var melee_range: float = 60.0
@export var ranged_attack_cooldown: float = 1.5
@export var hop_cooldown_min: float = 5.0
@export var hop_cooldown_max: float = 7.0
@export var hop_radius_min: float = 150.0
@export var hop_radius_max: float = 450.0

var hopping := false
var performing_ranged_attack := false
var next_hop_timer := 0.0
var ranged_attack_timer := 0.0
var performing_melee_attack := false

func configure_enemy() -> void:
	animation_player.animation_set_next("throw", "idle")
	animation_player.animation_set_next("jump", "idle")

	base_max_health = 450.0
	base_move_speed = 0.0
	base_damage = 20
	base_knockback_strength = 700.0
	base_attack_cooldown = 0.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

	if is_instance_valid(attack_hitbox):
		attack_hitbox.monitoring = false

	reset_hop_timer()
	start_hop()

func should_enter_moving_state() -> bool:
	if dead or spawning:
		return false

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.SPECIAL or current_state == EnemyState.STUNNED:
		return false

	return false

func should_start_attack() -> bool:
	if dead or spawning or hopping:
		return false

	if should_use_melee_attack():
		return true

	if is_player_too_close_for_ranged():
		return false

	return ranged_attack_timer >= ranged_attack_cooldown

func interrupt_actions() -> void:
	hopping = false
	performing_ranged_attack = false
	performing_melee_attack = false
	touching_entity = null
	touching_player = false

	if is_instance_valid(attack_hitbox):
		attack_hitbox.monitoring = false

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")

		EnemyState.ATTACKING:
			if should_use_melee_attack():
				start_melee_attack()
			else:
				start_ranged_attack()

		EnemyState.SPECIAL:
			pass

		EnemyState.STUNNED:
			interrupt_actions()
			animation_player.stop()

		EnemyState.DEAD:
			pass

func exit_state(_old_state: EnemyState) -> void:
	pass

func state_idle(_delta: float) -> void:
	if hopping:
		return

	if should_start_attack():
		set_state(EnemyState.ATTACKING)
		return

func state_attacking(_delta: float) -> void:
	pass

func state_special(_delta: float) -> void:
	pass

func enemy_process(delta: float) -> void:
	if dead or spawning:
		return

	if not hopping and not performing_ranged_attack and not performing_melee_attack:
		ranged_attack_timer += delta

	next_hop_timer -= delta
	if next_hop_timer <= 0.0 and not hopping and current_state != EnemyState.ATTACKING and current_state != EnemyState.STUNNED:
		start_hop()

func should_use_melee_attack() -> bool:
	return is_instance_valid(touching_entity)

func is_player_too_close_for_ranged() -> bool:
	return is_instance_valid(touching_entity)

func start_melee_attack() -> void:
	if dead or hopping:
		return

	performing_melee_attack = true
	performing_ranged_attack = false

	if animation_player.has_animation("attack"):
		animation_player.speed_scale = attack_animation_speed
		animation_player.play("attack")
	else:
		performing_melee_attack = false
		set_state(EnemyState.IDLE)

func start_ranged_attack() -> void:
	if dead or hopping:
		return

	performing_ranged_attack = true
	performing_melee_attack = false
	ranged_attack_timer = 0.0

	if animation_player.has_animation("throw"):
		animation_player.speed_scale = attack_animation_speed
		animation_player.play("throw")
	else:
		launch_projectile()
		performing_ranged_attack = false
		set_state(EnemyState.IDLE)

func launch_projectile() -> void:
	if dead or hopping:
		return

	var chosen_position = target.global_position + Vector2(
		randf_range(-shot_precision, shot_precision),
		randf_range(-shot_precision, shot_precision)
	)

	var projectile = projectile_scene.instantiate()
	projectile.start_pos = global_position + Vector2(30, -100)
	projectile.target_pos = chosen_position
	projectile.global_position = global_position
	projectile.chosen_area = chosen_position
	projectile.knockback_strength = projectile_knockback_strength
	projectile.damage = projectile_damage
	get_tree().current_scene.add_child(projectile)

func start_hop() -> void:
	if dead or spawning or hopping:
		return

	hopping = true
	performing_ranged_attack = false
	performing_melee_attack = false
	touching_entity = null
	touching_player = false

	set_state(EnemyState.SPECIAL)

	if animation_player.has_animation("jump_away"):
		animation_player.play("jump_away")
	else:
		teleport_to_hop_position()

		if animation_player.has_animation("jump"):
			animation_player.play("jump")
		else:
			finish_hop()

func teleport_to_hop_position() -> void:
	if not is_instance_valid(target):
		return

	var angle := randf() * TAU
	var distance := randf_range(hop_radius_min, hop_radius_max)

	var desired_position = target.global_position + Vector2.RIGHT.rotated(angle) * distance
	global_position = EnemyManager.get_valid_tile_near_point(desired_position, 10)

func finish_hop() -> void:
	hopping = false
	reset_hop_timer()
	set_state(EnemyState.IDLE)

	if animation_player.has_animation("idle"):
		animation_player.play("idle")

func reset_hop_timer() -> void:
	next_hop_timer = randf_range(hop_cooldown_min, hop_cooldown_max)

func animation_spawn_finished() -> void:
	if dead:
		return

	spawning = false
	set_state(EnemyState.IDLE)

func _apply_hitbox_damage() -> void:
	if dead:
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

func animation_attack_hit() -> void:
	if dead or current_state != EnemyState.ATTACKING:
		return

	_apply_hitbox_damage()
	attack_hit.emit()

func animation_landing_hit() -> void:
	if dead or not hopping:
		return

	_apply_hitbox_damage()
	attack_hit.emit()

func animation_attack_finished() -> void:
	if dead:
		return

	performing_melee_attack = false
	performing_ranged_attack = false
	super.animation_attack_finished()

func animation_throw_finished() -> void:
	if dead:
		return

	performing_ranged_attack = false
	animation_player.speed_scale = 1.0
	set_state(EnemyState.IDLE)

func animation_jump_reposition() -> void:
	teleport_to_hop_position()

	if animation_player.has_animation("jump"):
		animation_player.play("jump")
	else:
		finish_hop()

func animation_jump_finished() -> void:
	if dead:
		return

	finish_hop()

func die() -> void:
	if dead:
		return

	super.die()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return

	touching_entity = area.get_parent()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if not is_instance_valid(area):
		return

	if touching_entity and area.get_parent() == touching_entity:
		touching_entity = null
