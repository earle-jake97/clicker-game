extends BaseEnemy
var has_hidden = false
var hiding = false
var hide_timer = 0
var hide_duration = 2.0
var health_snapshot = 0.0
@onready var body: AnimatedSprite2D = $container/sprite/body

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
	hide_timer += delta
	if hiding and not hide_timer >= hide_duration:
		var t = hide_timer / hide_duration
		t = clamp(t, 0.0, 1.0)
		health = lerp(health_snapshot, max_health, t)
		if t >= 1.0:
			health = max_health
		health_bar.value = health
		handle_death(delta)
		return
	
	check_touch()
	get_target()
	if not dead and has_hidden and hide_timer >= hide_duration:
		add_to_group('enemy')
		hiding = false

	handle_death(delta)
	damage_cooldown += delta
	
	if not dead and health <= max_health/2 and not has_hidden:
		invlun(delta)
	
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
	elif not dead and not is_pushed and not is_frozen and not hiding:
		if is_instance_valid(target):
			if is_attacking:
				global_position = global_position.move_toward(target.global_position, speed * 0.75 * delta)
			else:
				global_position = global_position.move_toward(target.global_position, speed * delta)

	health_below_zero()


	z_index = round(global_position.y)

	attack_check()
	process_attack_check(delta)

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)

func start_attack():
	if reached_player:
		guarantee_hit = true
	animation_player.play("attack")
	is_attacking = true
	attack_duration = 0.0

func invlun(delta):
	if has_hidden:
		return
	hide_timer = 0
	health_snapshot = health
	remove_from_group("enemy")
	has_hidden = true
	hiding = true
	body.play("hide")
	animation_player.play("hide")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = true
		guarantee_hit = true
		touching_entity = area.get_parent()

	elif area.is_in_group("minion_hitbox"):
		touching_player = false
		touching_entity = area.get_parent()

func attack_check():
	if not hiding and touching_entity != null and damage_cooldown >= base_attack_speed + 1 and not is_attacking and not dead and not is_frozen:
		start_attack()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if touching_entity and area.get_parent() == touching_entity:
		touching_entity = null
		touching_player = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide":
		body.play("idle")
		animation_player.play("idle")
