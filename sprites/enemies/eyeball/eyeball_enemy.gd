extends BaseEnemy
@onready var projectile_spawn: Marker2D = $container/projectile_spawn
const EYEBALL = preload("res://sprites/enemies/eyeball/eyeball.png")
const EYEBALL_ATTACK = preload("res://sprites/enemies/eyeball/eyeball2.png")

const EYEBALL_PROJECTILE = preload("res://sprites/enemies/eyeball/eyeball_projectile.tscn")
var attack_cooldown = 5.0
var attack_timer = 3.0

func _ready() -> void:
	speed = 60
	base_speed = speed
	animation_player.animation_set_next("attack", "float")
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health

func _process(delta: float) -> void:
	attack_timer += delta
	look_at_player()
	if attack_timer >= attack_cooldown and not is_attacking:
		attack()
	if is_attacking:
		speed = base_speed/2
	else:
		speed = base_speed
	if dead:
		var color = sprite.modulate
		shadow.visible = false
		color.a = max(color.a - delta * 0.5, 0.0)
		sprite.modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()

	if health < max_health:
		health_bar.visible = true

	# Move toward player only if not waiting after attack
	if player and not dead and not is_pushed and not is_frozen:
		var direction = TestPlayer.global_position - global_position
		var distance = direction.length()
		if distance != 0:
			direction = direction.normalized()
		
		var desired_distance = 400.0
		
		if distance > desired_distance:
			# Move toward the player
			global_position += direction * speed * delta
		elif distance < desired_distance:
			# Move away from the player
			global_position -= direction * speed * delta

	if health <= 0:
		if not paid_out:
			paid_out = true
			player.add_cash(value)
		die()

	z_index = round(global_position.y)


func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)

func attack():
	is_attacking = true
	if not dead:
		sprite.texture = EYEBALL_ATTACK
		animation_player.play("attack")
	is_attacking = true
	await get_tree().create_timer(0.1667).timeout
	if not dead:
		fire_projectile()
	await get_tree().create_timer(0.3333).timeout
	if not dead:
		fire_projectile()
	await get_tree().create_timer(0.3).timeout
	if not dead:
		fire_projectile()
	is_attacking = false
	attack_timer = 0.0
	await get_tree().create_timer(0.2).timeout
	sprite.texture = EYEBALL

func fire_projectile():
	var projectile = EYEBALL_PROJECTILE.instantiate()
	projectile.global_position = projectile_spawn.global_position
	get_tree().current_scene.add_child(projectile)

func die():
	sprite.texture = EYEBALL_ATTACK
	progress_bar.hide()
	debuff_container.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()

func apply_debuff():
	debuff_container.update_debuffs()

func look_at_player():
	if not dead:
			if global_position.x > TestPlayer.global_position.x:
				container.scale.x = abs(container.scale.x)
			else:
				container.scale.x = -abs(container.scale.x)
