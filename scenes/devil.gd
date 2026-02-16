extends BaseEnemy

@onready var head: Sprite2D = $container/sprite/head
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const DEVON = preload("res://sprites/enemies/devil/devon.wav")
const NEW_DEVIL_HEAD = preload("res://sprites/enemies/devil/new_devil_head.png")
const NEW_DEVIL_HEAD_DEAD = preload("res://sprites/enemies/devil/new_devil_head_dead.png")
const NEW_DEVIL_HEAD_SMILE = preload("res://sprites/enemies/devil/new_devil_head_smile.png")

func _ready() -> void:
	attack_animation_length = 0.5333
	base_attack_speed = 0.7
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(min_speed, max_speed)
	base_speed = speed
	attack_speed = base_attack_speed
	if SoundManager.imp_spawn_sound():
		audio_stream_player_2d.pitch_scale = pitch_scale
		audio_stream_player_2d.play()
	nav2d.target_position = player_model.global_position

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
			head.texture = NEW_DEVIL_HEAD
			animation_player.play("walk")
				
			post_attack_delay = 0.0

	# Move toward player only if not waiting after attack
	move_towards_target(delta)

	health_below_zero()

	attack_check()
	process_attack_check(delta)
	
func start_attack():
	head.texture = NEW_DEVIL_HEAD_SMILE
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

func die():
	dead = true
	audio_stream_player_2d.stream = DEVON
	head.texture = NEW_DEVIL_HEAD_DEAD
	progress_bar.hide()
	debuff_container.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	died.emit()
