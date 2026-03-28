extends BaseEnemy

var exploded := false
var post_death_explosion := false

@onready var pie_pos: Marker2D = $container/sprite/body/pie/pie_pos
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

const CLOWN_EXPLOSION = preload("uid://c2k7a5h1qbeer")

func configure_enemy() -> void:
	base_max_health = 250.0
	base_move_speed = 120.0
	base_damage = 0
	base_attack_cooldown = 0.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0

	value = 0
	item_rolled = true

func should_enter_moving_state() -> bool:
	if dead or spawning or exploded:
		return false

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.SPECIAL or current_state == EnemyState.STUNNED:
		return false

	if not is_instance_valid(target):
		return false

	return true

func should_start_attack() -> bool:
	return false

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			play_walk_animation()

		EnemyState.MOVING:
			play_walk_animation()

		EnemyState.SPECIAL:
			pass

		EnemyState.STUNNED:
			animation_player.stop()

		EnemyState.DEAD:
			pass

func exit_state(_old_state: EnemyState) -> void:
	pass

func state_idle(_delta: float) -> void:
	if should_enter_moving_state():
		set_state(EnemyState.MOVING)

func state_moving(delta: float) -> void:
	if not is_instance_valid(target):
		set_state(EnemyState.IDLE)
		return

	move_directly_toward_target(delta, 0.0)

func state_special(_delta: float) -> void:
	pass

func enemy_process(_delta: float) -> void:
	pass

func explode() -> void:
	if exploded or dead:
		return

	exploded = true
	can_move = false
	set_state(EnemyState.SPECIAL)

	if animation_player.has_animation("fall"):
		animation_player.play("fall")
	else:
		health = 0
		return

	await get_tree().create_timer(0.556).timeout

	if dead:
		return

	health = 0
	health_below_zero()

func die() -> void:
	if dead:
		return

	if not post_death_explosion:
		post_death_explosion = true

		var explosion = CLOWN_EXPLOSION.instantiate()
		explosion.global_position = pie_pos.global_position
		get_tree().current_scene.get_node("y_sort_node").add_child(explosion)
		audio_stream_player_2d.play()

	super.die()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	explode()
