extends BaseEnemy

@onready var bleed_icon: Sprite2D = $"bleed stacks"
@onready var bleed_label: Label = $"bleed stacks/Label"
@onready var face: Sprite2D = $sprite/spritebody/face

func _ready() -> void:
	base_attack_speed = 2.0
	face.visible = false
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(min_speed, max_speed)
	base_speed = speed
	attack_speed = base_attack_speed

func _process(delta: float) -> void:
	
	if bleed_stacks > 0:
		bleed_icon.visible = true
		bleed_label.text = "x" + str(bleed_stacks)
		debuffs.append(debuff.Debuff.BLEED)
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
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			animation_player.play("walk")
				
			post_attack_delay = 0.0

	# Move toward player only if not waiting after attack
	elif player and not is_attacking and not dead and not is_frozen:
		global_position = global_position.move_toward(player.player.global_position, speed * delta)

	if health <= 0:
		if not paid_out:
			paid_out = true
			player.add_cash(value)
		die()

	z_index = round(global_position.y)

	if touching_player and damage_cooldown >= player.iframe_duration and not is_attacking and not dead and not is_frozen:
		reached_player = true
		start_attack()

	if is_attacking and not dead:
		process_attack(delta)

func start_attack():
	animation_player.play("attack")

	is_attacking = true
	attack_duration = 0.0

func process_attack(delta):
	attack_duration += delta

	if attack_duration >= 1.7 and is_attacking:
		player.take_damage(damage, armor_penetration)
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

func apply_debuff():
	debuff_container.update_debuffs()

func die():
	debuff_container.hide()
	face.visible = true
	bleed_icon.visible = false
	progress_bar.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()
