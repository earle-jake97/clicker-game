extends BaseEnemy
var controller = PlayerController
var dropped_money = false
var teleport_cooldown = 3.0
var teleport_timer = 0.0
var base_attack_cooldown = 3.0
var base_attack_timer = 0.0
var clown_timer = 0.0
var clown_cooldown = 20.0
@onready var wand_tip: Marker2D = $container/sprite/body/arm/wand_tip
@onready var pivot: Marker2D = $container/sprite/body/pivot
const BALL_PROJECTILE = preload("uid://djwlevxw3n2cf")
const BARRAGE_SHOTS = 10
@export var bounding_box = Vector2.ZERO
const SPOTLIGHT = preload("uid://b7npbrfkm5ryl")
const CLOWN = preload("uid://sleopvmj67ny")
var goal_location = Vector2.ZERO
var start_location = Vector2.ZERO
var attacking = false
signal halftime
signal magician_dead
var half_hp = false
var simon_says_active = false

func extra_ready():
	animation_player = $container/AnimationPlayer
	animation_player.animation_set_next("teleport_finish", "float_in_place")
	animation_player.animation_set_next("barrage_1", "float_in_place")
	animation_player.animation_set_next("barrage_2", "float_in_place")
	animation_player.animation_set_next("horn", "float_in_place")
	animation_player.animation_set_next("float_left", "float_in_place")
	animation_player.animation_set_next("float_right", "float_in_place")
	
	if PlayerController.difficulty >= 15:
		max_health = max_health * pow(1 + 0.12, PlayerController.difficulty)
	else:
		if controller.difficulty == 0:
			max_health = 3000
		else:
			max_health = 8000
	health = max_health
	progress_bar.value = max_health

func teleport_attack():
	attacking = true
	animation_player.play("teleport_start")
	await animation_player.animation_finished
	animation_player.play("teleport_finish")
	var random_pos = Vector2(randf_range(130, bounding_box.x), randf_range(200, bounding_box.y))
	if simon_says_active:
		var positions = [Vector2(800, 175), Vector2(800, 777), Vector2(1250, 400), Vector2(335, 400)]
		random_pos = positions.pick_random()
	global_position = random_pos
	tele_projectiles()
	await animation_player.animation_finished
	attacking = false

func tele_projectiles():
	spawn_projectile(Vector2.DOWN)
	spawn_projectile(Vector2.LEFT)
	spawn_projectile(Vector2.UP)
	spawn_projectile(Vector2.RIGHT)
	spawn_projectile(Vector2(0.5, 0.5))
	spawn_projectile(Vector2(-0.5, 0.5))
	spawn_projectile(Vector2(0.5, -0.5))
	spawn_projectile(Vector2(-0.5, -0.5))
	
func summon_clowns():
	attacking = true
	animation_player.play("horn")
	await get_tree().create_timer(1.35)
	var clown_spawn_1 = CLOWN.instantiate()
	var clown_spawn_2 = CLOWN.instantiate()
	clown_spawn_1.global_position = Vector2(-366, 460)
	get_tree().current_scene.get_node("y_sort_node").add_child(clown_spawn_1)
	clown_spawn_2.global_position = Vector2(1620, 460)
	get_tree().current_scene.get_node("y_sort_node").add_child(clown_spawn_2)
	attacking = false
	
func barrage_attack():
	attacking = true
	var init_angle = 180.0
	var final_angle = 1.0
	if player_model.global_position.y <= global_position.y:
		final_angle = 358.0
		animation_player.play("barrage_2")
	else:
		animation_player.play("barrage_1")
	await get_tree().create_timer(0.31).timeout
	for i in range(BARRAGE_SHOTS + 1):
		var t = float(i) / BARRAGE_SHOTS
		var angle = lerp_angle(
			deg_to_rad(init_angle),
			deg_to_rad(final_angle),
			t
		)
		var direction = Vector2.from_angle(angle)
		spawn_projectile(direction, true)
		await get_tree().create_timer(0.025).timeout
	attacking = false

func spawn_projectile(direction, from_wand: bool = false):
	var projectile = BALL_PROJECTILE.instantiate()
	projectile.direction = direction
	if from_wand:
		projectile.global_position = wand_tip.global_position
	else:
		projectile.global_position = pivot.global_position
	get_tree().current_scene.get_node("y_sort_node").add_child(projectile)

func show_damage_number(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	damage_batcher.add_damage(amount, damage_type)

func summon_simon():
	animation_player.stop()
	await get_tree().process_frame
	animation_player.play("summon_simon")
	await get_tree().create_timer(1.0).timeout
	global_position = Vector2(-10000, -10000)
	base_attack_timer = -6.0
	await get_tree().create_timer(6.0).timeout
	teleport_attack()

func extra_processing(delta):
	if health <= max_health * 0.6 and not half_hp:
		half_hp = true
		summon_simon()
		halftime.emit()
		base_attack_timer = -5.0

	teleport_timer += delta
	base_attack_timer += delta
	clown_timer += delta
	if base_attack_cooldown <= base_attack_timer:
		base_attack_timer = 0.0
		handle_attack()

func handle_attack():
	if dead:
		return

	var random_attack = randf_range(0, 1)
	if random_attack <= 0.44 and teleport_timer >= teleport_cooldown or simon_says_active:
		teleport_timer = 0.0
		teleport_attack()
	elif random_attack <= 0.80 and clown_timer >= clown_cooldown:
		clown_timer = 0.0
		summon_clowns()
	else:
		barrage_attack()

func change_position(pos):
	global_position = pos

func get_center():
	return pivot

func set_simon_says(value):
	simon_says_active = value

func extra_death_parameters():
	magician_dead.emit()
	if dropped_money:
		return
	dropped_money = true
	for i in range(3):
		var money = MONEY_DROP.instantiate()
		money.value = 1
		money.global_position = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
		money.z_index += 1
		var ran = randf_range(0, 1)
		if ran <= 0.2:
			money.value = 5
		if ran <= 0.1:
			money.value = 10
		if i == 2:
			money.value = 10
		get_parent().add_child(money)
