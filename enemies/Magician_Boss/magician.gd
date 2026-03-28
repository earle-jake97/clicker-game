extends BaseEnemy

var controller = PlayerController
var dropped_money := false

@export var teleport_cooldown: float = 3.0
@export var clown_cooldown: float = 20.0
@export var base_attack_interval: float = 3.0
@export var bounding_box: Vector2 = Vector2.ZERO

var teleport_timer := 0.0
var base_attack_timer := 0.0
var clown_timer := 0.0

@onready var wand_tip: Marker2D = $container/sprite/body/arm/wand_tip
@onready var pivot: Marker2D = $container/sprite/body/pivot

const BALL_PROJECTILE = preload("uid://djwlevxw3n2cf")
const BARRAGE_SHOTS := 10
const SPOTLIGHT = preload("uid://b7npbrfkm5ryl")
const CLOWN = preload("uid://sleopvmj67ny")

var goal_location := Vector2.ZERO
var start_location := Vector2.ZERO
var attacking := false
var half_hp := false
var simon_says_active := false

signal halftime
signal magician_dead

func configure_enemy() -> void:
	animation_player = $container/AnimationPlayer
	animation_player.animation_set_next("teleport_finish", "float_in_place")
	animation_player.animation_set_next("barrage_1", "float_in_place")
	animation_player.animation_set_next("barrage_2", "float_in_place")
	animation_player.animation_set_next("horn", "float_in_place")
	animation_player.animation_set_next("float_left", "float_in_place")
	animation_player.animation_set_next("float_right", "float_in_place")

	base_move_speed = 0.0
	base_damage = 0
	base_attack_cooldown = 0.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

	if PlayerController.difficulty >= 15:
		base_max_health = base_max_health * pow(1.0 + 0.12, PlayerController.difficulty)
	else:
		if controller.difficulty == 0:
			base_max_health = 3000.0
		else:
			base_max_health = 8000.0

func can_receive_status_effect(_effect: EnemyStatusEffect) -> bool:
	return false

func should_enter_moving_state() -> bool:
	return false

func should_start_attack() -> bool:
	if dead or spawning or attacking:
		return false

	return false

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			if animation_player.has_animation("float_in_place"):
				animation_player.play("float_in_place")

		EnemyState.SPECIAL:
			pass

		EnemyState.STUNNED:
			# Bosses should probably not get here, but keep safe behavior.
			animation_player.stop()

		EnemyState.DEAD:
			pass

func exit_state(_old_state: EnemyState) -> void:
	pass

func state_idle(_delta: float) -> void:
	pass

func state_special(_delta: float) -> void:
	pass

func enemy_process(delta: float) -> void:
	if dead or spawning:
		return

	if health <= max_health * 0.6 and not half_hp:
		half_hp = true
		halftime.emit()
		base_attack_timer = -5.0
		summon_simon()
		return

	if attacking:
		return

	teleport_timer += delta
	base_attack_timer += delta
	clown_timer += delta

	if base_attack_timer >= base_attack_interval:
		base_attack_timer = 0.0
		handle_attack()

func handle_attack() -> void:
	if dead or attacking:
		return

	var random_attack := randf_range(0.0, 1.0)
	print("Random_attack value: ", random_attack)

	if (random_attack <= 0.44 and teleport_timer >= teleport_cooldown) or simon_says_active:
		teleport_timer = 0.0
		teleport_attack()
	elif random_attack <= 0.80 and clown_timer >= clown_cooldown:
		clown_timer = 0.0
		summon_clowns()
	else:
		barrage_attack()

func teleport_attack() -> void:
	if dead:
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	animation_player.play("teleport_start")
	await animation_player.animation_finished

	if dead:
		return

	animation_player.play("teleport_finish")

	var random_pos := Vector2(
		randf_range(130.0, bounding_box.x),
		randf_range(200.0, bounding_box.y)
	)

	if simon_says_active:
		var positions = [
			Vector2(800, 175),
			Vector2(800, 777),
			Vector2(1250, 400),
			Vector2(335, 400)
		]
		random_pos = positions.pick_random()

	global_position = random_pos
	tele_projectiles()

	await animation_player.animation_finished

	if dead:
		return

	attacking = false
	set_state(EnemyState.IDLE)

func tele_projectiles() -> void:
	spawn_projectile(Vector2.DOWN)
	spawn_projectile(Vector2.LEFT)
	spawn_projectile(Vector2.UP)
	spawn_projectile(Vector2.RIGHT)
	spawn_projectile(Vector2(0.5, 0.5))
	spawn_projectile(Vector2(-0.5, 0.5))
	spawn_projectile(Vector2(0.5, -0.5))
	spawn_projectile(Vector2(-0.5, -0.5))

func summon_clowns() -> void:
	if dead:
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	animation_player.play("horn")
	await get_tree().create_timer(1.35).timeout

	if dead:
		return

	var clown_spawn_1 = CLOWN.instantiate()
	var clown_spawn_2 = CLOWN.instantiate()

	clown_spawn_1.global_position = Vector2(-366, 460)
	get_tree().current_scene.get_node("y_sort_node").add_child(clown_spawn_1)

	clown_spawn_2.global_position = Vector2(1620, 460)
	get_tree().current_scene.get_node("y_sort_node").add_child(clown_spawn_2)

	attacking = false
	set_state(EnemyState.IDLE)

func barrage_attack() -> void:
	if dead or not is_instance_valid(player_model):
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	var init_angle := 180.0
	var final_angle := 1.0

	if player_model.global_position.y <= global_position.y:
		final_angle = 358.0
		animation_player.play("barrage_2")
	else:
		animation_player.play("barrage_1")

	await get_tree().create_timer(0.31).timeout

	if dead:
		return

	for i in range(BARRAGE_SHOTS + 1):
		var t := float(i) / BARRAGE_SHOTS
		var angle := lerp_angle(
			deg_to_rad(init_angle),
			deg_to_rad(final_angle),
			t
		)
		var direction := Vector2.from_angle(angle)
		spawn_projectile(direction, true)
		await get_tree().create_timer(0.025).timeout

		if dead:
			return

	attacking = false
	set_state(EnemyState.IDLE)

func spawn_projectile(direction: Vector2, from_wand: bool = false) -> void:
	var projectile = BALL_PROJECTILE.instantiate()
	projectile.direction = direction

	if from_wand:
		projectile.global_position = wand_tip.global_position
	else:
		projectile.global_position = pivot.global_position

	get_tree().current_scene.get_node("y_sort_node").add_child(projectile)

func show_damage_number(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL) -> void:
	damage_batcher.add_damage(amount, damage_type)

func summon_simon() -> void:
	if dead:
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	animation_player.stop()
	await get_tree().process_frame

	if dead:
		return

	animation_player.play("summon_simon")
	await get_tree().create_timer(1.0).timeout

	if dead:
		return

	global_position = Vector2(-10000, -10000)
	base_attack_timer = -6.0

	await get_tree().create_timer(6.0).timeout

	if dead:
		return

	attacking = false
	teleport_attack()

func change_position(pos: Vector2) -> void:
	global_position = pos

func get_center() -> Marker2D:
	return pivot

func set_simon_says(value: bool) -> void:
	simon_says_active = value

func die() -> void:
	if dead:
		return

	magician_dead.emit()

	if not dropped_money:
		dropped_money = true
		for i in range(3):
			var money = MONEY_DROP.instantiate()
			money.value = 1
			money.global_position = global_position + Vector2(
				randf_range(-100, 100),
				randf_range(-100, 100)
			)
			money.z_index += 1

			var ran := randf_range(0.0, 1.0)
			if ran <= 0.2:
				money.value = 5
			if ran <= 0.1:
				money.value = 10
			if i == 2:
				money.value = 10

			get_parent().add_child(money)

	super.die()
