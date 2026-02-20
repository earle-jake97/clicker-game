extends BaseEnemy
@onready var projectile_spawn: Marker2D = $container/projectile_spawn
const EYEBALL = preload("res://sprites/enemies/eyeball/eyeball.png")
const EYEBALL_ATTACK = preload("res://sprites/enemies/eyeball/eyeball2.png")

const EYEBALL_PROJECTILE = preload("res://sprites/enemies/eyeball/eyeball_projectile.tscn")
var attack_cooldown = 5.0
var attack_timer = 3.0

func extra_ready():
	unique_attack = true
	unique_movement = true
	animation_player.animation_set_next("attack", "float")

func extra_processing(delta):
	attack_timer += delta
	if attack_timer >= attack_cooldown and not is_attacking:
		attack()
	if is_attacking:
		speed = base_speed/2
	else:
		speed = base_speed
	# Move toward player only if not waiting after attack
	if player and not dead and not is_pushed and not is_frozen:
		var direction = player_model.global_position - global_position
		var distance = direction.length()
		if distance != 0:
			direction = direction.normalized()
		
		var desired_distance = 400.0
		if distance > desired_distance:
			# Move toward the player
			global_position += direction * speed * delta
		else:
			# Move away from the player
			global_position -= direction * speed * delta

func attack():
	is_attacking = true
	attack_timer = 0.0
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
	await get_tree().create_timer(0.2).timeout
	sprite.texture = EYEBALL

func fire_projectile():
	var projectile = EYEBALL_PROJECTILE.instantiate()
	projectile.global_position = projectile_spawn.global_position
	get_tree().current_scene.add_child(projectile)

func extra_death_parameters():
	sprite.texture = EYEBALL_ATTACK
