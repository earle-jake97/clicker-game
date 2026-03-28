extends BaseEnemy

var controller = PlayerController

@onready var minion_ball: Node2D = $container/sprite/Minion_ball
@onready var head: Sprite2D = $container/sprite/Head_Node/Head
@onready var animation_player_head: AnimationPlayer = $container/sprite/Head_Node/Head/AnimationPlayer
@onready var pivot: Marker2D = $container/sprite/Body/pivot
@onready var jump_timer: Timer = $"Jump timer"
@onready var attack_duration_timer: Timer = $"Attack Duration Timer"

const DIVING_MINION = preload("res://sprites/enemies/devil/diving_minion.tscn")
const SHOCKWAVE = preload("res://sprites/enemies/devil_boss/shockwave.tscn")
const TELEGRAPH = preload("res://scenes/telegraph.tscn")
const FIREBALL = preload("res://sprites/enemies/devil_boss/fireball.tscn")

const HEAD = preload("res://sprites/enemies/devil_boss/head.png")
const HEAD_POG = preload("res://sprites/enemies/devil_boss/head_pog.png")
const HEAD_EYES_CLOSED = preload("res://sprites/enemies/devil_boss/head_eyes_closed.png")
const HEAD_POG_EYES_CLOSED = preload("res://sprites/enemies/devil_boss/head_pog_eyes_closed.png")

const MEDITATE_INTERVAL := 6.0
const THROW_INTERVAL := 6.0
const FIREBALL_INTERVAL := 1.5
const MEDITATE_TIME := 2.3
const GLOBAL_INTERVAL := 3.5
const FIREBALL_TRAVEL_TIME := 0.8
const JUMP_WINDUP := 0.5
const JUMP_AIRTIME := 0.5
const TIME_TO_LAND := 0.2

var can_fireball := true
var mouth_timer := 0.0
var armor := 50
var meditate_timer := 0.0
var meditating := false
var jump_pos := Vector2.ZERO
var dropped_money := false
var attacking := false

var global_cooldown := 0.0
var throw_cooldown := 0.0
var fireball_cooldown := 0.0
var meditate_cooldown := 0.0

signal halftime
signal magician_dead

func configure_enemy() -> void:
	animation_player = $container/sprite/AnimationPlayer
	animation_player.animation_set_next("slam", "idle")
	animation_player.animation_set_next("meditate", "idle")
	animation_player.animation_set_next("throw_minions", "idle")
	animation_player.animation_set_next("jump", "idle")

	base_move_speed = 0.0
	base_damage = 0
	base_attack_cooldown = 0.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

	if PlayerController.difficulty >= 15:
		base_max_health = base_max_health * pow(1.0 + 0.12, PlayerController.difficulty)
	else:
		if controller.difficulty == 0:
			base_max_health = 99999.0
		else:
			base_max_health = 8000.0

func can_receive_status_effect(_effect: EnemyStatusEffect) -> bool:
	return false

func should_enter_moving_state() -> bool:
	return false

func should_start_attack() -> bool:
	return false

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")

		EnemyState.SPECIAL:
			pass

		EnemyState.STUNNED:
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

	mouth_timer += delta

	if can_fireball:
		if health <= max_health / 4.0:
			fireball_cooldown += delta * 2.5
		elif health <= max_health / 2.0:
			fireball_cooldown += delta * 2.0
		else:
			fireball_cooldown += delta

	look_at_target()

	throw_cooldown += delta
	meditate_cooldown += delta
	global_cooldown += delta
	meditate_timer += delta

	if meditate_timer >= MEDITATE_TIME and meditating:
		bleed_stacks = 0
		clear_all_status_effects()
		meditating = false

	if fireball_cooldown >= FIREBALL_INTERVAL and not dead:
		fireball_cooldown = 0.0
		shoot_fireball()

	if head.texture == HEAD_POG and mouth_timer >= 0.5:
		head.texture = HEAD
	elif head.texture == HEAD_POG_EYES_CLOSED and mouth_timer >= 0.5:
		head.texture = HEAD_EYES_CLOSED

	if head.texture == HEAD_EYES_CLOSED and not meditating:
		head.texture = HEAD

	handle_attack()

func handle_attack() -> void:
	if dead or attacking:
		return

	if global_cooldown < GLOBAL_INTERVAL:
		return

	var ran := randf_range(0.0, 1.0)

	if ran <= 0.25 and throw_cooldown >= THROW_INTERVAL:
		throw_minions()
	elif ran <= 0.5 and bleed_stacks > 0 and meditate_cooldown >= MEDITATE_INTERVAL:
		meditate()
	elif ran <= 0.75:
		jump_attack()
	else:
		slam()

	global_cooldown = 0.0

func throw_minions() -> void:
	if dead:
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	throw_cooldown = 0.0
	minion_ball.visible = true
	animation_player.play("throw_minions")

	for i in range(5):
		var enemy = DIVING_MINION.instantiate()
		var enemy_chosen_position = EnemyManager.get_valid_tile_near_point(
			Vector2(randf_range(-1000, 1000), randf_range(-500, 500))
		)

		enemy.target_pos = enemy_chosen_position
		enemy.shadow_position = enemy_chosen_position
		enemy.global_position = Vector2(enemy_chosen_position.x, randf_range(-3500, -2500))
		enemy.speed = randf_range(500, 900)

		if enemy is BaseEnemy:
			var decay_modifier := DecayModifier.new()
			enemy.add_modifier(decay_modifier)

		get_parent().add_child(enemy)

	await animation_player.animation_finished

	if dead:
		return

	minion_ball.visible = false
	attacking = false
	set_state(EnemyState.IDLE)

func jump_attack() -> void:
	if dead or not is_instance_valid(player_model):
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	animation_player.play("jump")
	jump_timer.start(JUMP_WINDUP + JUMP_AIRTIME)
	set_attack_duration(JUMP_WINDUP + JUMP_AIRTIME + TIME_TO_LAND)

	jump_pos = player_model.global_position + Vector2(
		randf_range(-100, 100),
		randf_range(-100, 100)
	)

	var telegraph = TELEGRAPH.instantiate()
	telegraph.max_scale = Vector2(2.8, 1.75)
	telegraph.damage = damage + (controller.difficulty * 0.2)
	telegraph.armor_penetration = 0
	telegraph.duration = JUMP_WINDUP + JUMP_AIRTIME + TIME_TO_LAND
	telegraph.global_position = jump_pos
	telegraph.knockback_strength = 1400.0
	get_tree().current_scene.add_child(telegraph)

	await get_tree().create_timer(JUMP_WINDUP + JUMP_AIRTIME + TIME_TO_LAND).timeout

	if dead:
		return

	attacking = false
	set_state(EnemyState.IDLE)

func change_position(pos: Vector2) -> void:
	global_position = pos

func shoot_fireball() -> void:
	if dead or not is_instance_valid(player_model):
		return

	open_mouth()

	var telegraph = TELEGRAPH.instantiate()
	telegraph.damage = damage + (controller.difficulty * 0.2)
	telegraph.armor_penetration = 0
	telegraph.duration = FIREBALL_TRAVEL_TIME

	if dead:
		telegraph.duration = FIREBALL_TRAVEL_TIME * 2.5

	var chosen_position = player_model.global_position + Vector2(
		randf_range(-100, 100),
		randf_range(-100, 100)
	)
	telegraph.global_position = chosen_position
	get_tree().current_scene.add_child(telegraph)

	var projectile = FIREBALL.instantiate()
	projectile.start_pos = head.global_position
	projectile.target_pos = chosen_position
	projectile.flight_time = FIREBALL_TRAVEL_TIME

	if dead:
		projectile.flight_time = FIREBALL_TRAVEL_TIME * 2.5

	projectile.global_position = head.global_position - Vector2(300, 0)
	get_tree().current_scene.add_child(projectile)

func open_mouth() -> void:
	if meditating:
		head.texture = HEAD_POG_EYES_CLOSED
	else:
		head.texture = HEAD_POG

	mouth_timer = 0.0

func meditate() -> void:
	if dead:
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	meditate_timer = 0.0
	head.texture = HEAD_EYES_CLOSED
	meditating = true
	animation_player.play("meditate")
	meditate_cooldown = 0.0

	await animation_player.animation_finished

	if dead:
		return

	attacking = false
	set_state(EnemyState.IDLE)

func slam() -> void:
	if dead or not is_instance_valid(player_model):
		return

	attacking = true
	set_state(EnemyState.SPECIAL)

	animation_player.play("slam")

	var ran = player_model.global_position + Vector2(2000, randf_range(-200, 200))
	var shockwave = SHOCKWAVE.instantiate()
	add_child(shockwave)
	shockwave.chosen_pos = ran
	shockwave.global_position = ran

	await animation_player.animation_finished

	if dead:
		return

	attacking = false
	set_state(EnemyState.IDLE)

func set_attack_duration(time: float) -> void:
	can_fireball = false
	attack_duration_timer.start(time)

func _on_jump_timer_timeout() -> void:
	change_position(jump_pos)

func _on_attack_duration_timer_timeout() -> void:
	can_fireball = true

func clear_all_status_effects() -> void:
	var effects_to_remove: Array[EnemyStatusEffect] = []

	for effect in status_effects:
		if is_instance_valid(effect):
			effects_to_remove.append(effect)

	for effect in effects_to_remove:
		remove_status_effect(effect)

func show_damage_number(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL) -> void:
	damage_batcher.add_damage(amount, damage_type)

func die() -> void:
	if dead:
		return

	head.texture = HEAD_POG_EYES_CLOSED
	magician_dead.emit()

	if not dropped_money:
		dropped_money = true
		for i in range(3):
			var money = MONEY_DROP.instantiate()
			money.value = 1
			money.global_position = pivot.global_position + Vector2(
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
