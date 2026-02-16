extends BaseEnemy

@onready var head: Sprite2D = $sprite/head
@onready var head_anim: AnimationPlayer = $head_anim
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
var rise_timer = 0.0

func _ready() -> void:
	base_attack_speed = 1.0
	audio_stream_player_2d.pitch_scale = randf_range(0.8, 1.05)
	health_bar.visible = false
	max_health = PlayerController.difficulty * 35
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = 40
	base_speed = speed
	attack_speed = base_attack_speed
	audio_stream_player_2d.play()

func _process(delta: float) -> void:
	rise_timer += delta
	for entity in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(entity):
			continue
		
		var distance = global_position.distance_to(entity.global_position)

		var is_closer = true
		if is_instance_valid(target):
			is_closer = distance < global_position.distance_to(target.global_position)
		
		if entity.has_method("is_alive") and entity.is_alive() and is_closer and entity.global_position.x <= global_position.x:
			target = entity
		else:
			target = player_model

	if is_pushed:
		global_position = global_position.move_toward(Vector2(40000, global_position.y), push_strength * 300 * delta)
	pushback_timer += delta
	if pushback_timer >= pushback_length:
		is_pushed = false

	if dead:
		var color = sprite.modulate
		shadow.visible = false
		color.a = max(color.a - delta * 0.5, 0.0)
		sprite.modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()
	damage_cooldown += delta

	if health < max_health:
		health_bar.visible = true

	# Handle post-attack delay
	if waiting_after_attack:
		head_anim.play("bob")
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			animation_player.play("walk")
				
			post_attack_delay = 0.0

	# Move toward player only if not waiting after attack
	elif rise_timer >= 1.05 and player and not is_attacking and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 20.0:
		global_position = global_position.move_toward(target.global_position, speed * delta)
		animation_player.play("walk")

	if health <= 0:
		die()

	if touching_player and damage_cooldown >= player.iframe_duration and not is_attacking and not dead and not is_frozen:
		reached_player = true
		start_attack()

	if is_attacking and not dead:
		process_attack(delta)

func push_back(strength: float):
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0

func start_attack():
	head_anim.play("bite")
	animation_player.play("attack")
	is_attacking = true
	attack_duration = 0.0

func process_attack(delta):
	attack_duration += delta

	if attack_duration >= 1.1 and is_attacking:
		if target.has_method("take_damage") and touching_player:
			target.take_damage(damage, armor_penetration)

		is_attacking = false
		waiting_after_attack = true
		attack_duration = 0.0
		damage_cooldown = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = false
		reached_player = false

func die():
	head_anim.stop()
	progress_bar.hide()
	debuff_container.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()

func apply_debuff():
	debuff_container.update_debuffs()
