extends BaseEnemy

@onready var projectile_spawn: Marker2D = $container/projectile_spawn

const EYEBALL_PROJECTILE = preload("uid://b5rdqcntxpgwh")

@export var desired_distance: float = 400.0
@export var distance_tolerance: float = 30.0
@export var attack_range: float = 1000.0

var performing_attack := false

func configure_enemy() -> void:
	animation_player.animation_set_next("attack", "float")

	base_max_health = 180.0
	base_move_speed = 50.0
	base_damage = 1
	base_attack_cooldown = 5.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

func should_enter_moving_state() -> bool:
	if dead or spawning:
		return false

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.SPECIAL or current_state == EnemyState.STUNNED:
		return false

	if not is_instance_valid(target):
		return false

	return true

func should_start_attack() -> bool:
	if dead or spawning:
		return false

	if current_state == EnemyState.STUNNED:
		return false

	if performing_attack:
		return false

	if not is_instance_valid(target):
		return false

	if not target_in_range():
		return false

	return can_attack()

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			if animation_player.has_animation("float"):
				animation_player.play("float")

		EnemyState.MOVING:
			if animation_player.has_animation("float"):
				animation_player.play("float")

		EnemyState.ATTACKING:
			start_attack()

		EnemyState.STUNNED:
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

	move_to_preferred_distance(delta)

func state_attacking(_delta: float) -> void:
	pass

func enemy_process(_delta: float) -> void:
	pass

func move_to_preferred_distance(delta: float) -> void:
	if dead or spawning or is_pushed:
		return

	if not is_instance_valid(target):
		return

	var direction = target.global_position - global_position
	var distance = direction.length()

	if distance == 0.0:
		return

	direction = direction.normalized()

	var current_move_speed := move_speed
	if performing_attack:
		current_move_speed *= 0.5

	if distance > desired_distance + distance_tolerance:
		global_position += direction * current_move_speed * delta
	elif distance < desired_distance - distance_tolerance:
		global_position -= direction * current_move_speed * delta

func target_in_range() -> bool:
	if not is_instance_valid(target):
		return false

	return global_position.distance_to(target.global_position) <= attack_range

func start_attack() -> void:
	if dead:
		return

	performing_attack = true

	if animation_player.has_animation("attack"):
		animation_player.speed_scale = attack_animation_speed
		animation_player.play("attack")
	else:
		fire_projectile()
		fire_projectile()
		fire_projectile()
		animation_attack_finished()

func fire_projectile() -> void:
	if dead:
		return

	var projectile = EYEBALL_PROJECTILE.instantiate()
	projectile.global_position = projectile_spawn.global_position
	get_tree().current_scene.add_child(projectile)

func animation_attack_finished() -> void:
	if dead:
		return

	performing_attack = false
	super.animation_attack_finished()

func die() -> void:
	if dead:
		return

	super.die()
