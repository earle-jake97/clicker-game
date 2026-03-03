extends Node2D
class_name BaseEnemy

var is_frozen = false
signal died
var player = PlayerController
var player_model
@export var speed: float = 0
@export var damage: int = 0
@export var armor_penetration: int = 0
var health: float = 10
@export var max_health: float = 10
@onready var health_bar: TextureProgressBar = $ProgressBar
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@onready var debuff_container: HBoxContainer = $debuff_container
@export var value_min: int
@export var value_max: int
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var shadow: Sprite2D = $container/shadow
@onready var animation_player: AnimationPlayer = $container/AnimationPlayer
@onready var container: Node = $container
@onready var sprite: Node2D = $container/sprite
@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var area_2d: Area2D = $container/Area2D
var variant = EnemyManager.variant.NORMAL

const MONEY_DROP = preload("uid://c0vl7qr3w4dfp")

var independent_look = false
var guarantee_hit = false
var debuffs = []
var touching_entity: Node = null
var bleed_stacks = 0
var damage_cooldown = 0.0
var touching_player = false
var attack_duration = 0.0
var is_attacking = false
var reached_player = false
var post_attack_delay = 0.0
var waiting_after_attack = false
var death_timer = 0.0
var dead = false
var paid_out = false
var value = 0
var base_speed = 0
var attack_speed = 0
var push_strength = 0.0
var pushback_length = 2.0
var pushback_timer = 0.0
var is_pushed = false
var target = player_model
var moving = true
var pitch_scale = randf_range(0.9, 1.3)
var base_attack_speed = 0.7
var attack_animation_length = 0.5333
var knockback_strength = 0
var trigger_knockback = true
var can_move = true
var unique_attack = false
var unique_movement = false
var path_update_timer = 0.0
var update_interval = 0.1
var item_rolled = false
var decay = false
var active = false
var spawning = true
var catchup_timer = 0.0
var catchup_interval = 0.5

func _ready() -> void:
	await get_tree().process_frame
	player_model = PlayerController.get_player_body()
	if EnemyManager.get_all_enemies().size() >= 50:
		shadow.visible = false
	EnemyManager.optimize.connect(_optimize)
	EnemyManager.kill_all.connect(_die_from_manager)
	EnemyManager.register(self)
	value = randi_range(value_min, value_max)
	extra_ready()
	if health_bar:
		health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = base_speed
	attack_speed = base_attack_speed
	nav2d.target_position = player_model.global_position
	value = 1
	if animation_player.has_animation("spawn"):
		animation_player.play("spawn")
		await animation_player.animation_finished
	spawning = false
	await get_tree().physics_frame
	nav2d.target_position = player_model.global_position
	
func extra_ready():
	pass

func _physics_process(delta: float) -> void:
	if spawning:
		return
	path_update_timer += delta
	catchup_timer += delta
	check_touch()
	get_target()
	damage_cooldown += delta
	if health < max_health:
		health_bar.visible = true
	extra_processing(delta)
	if catchup_timer >= catchup_interval:
		catch_up()
	if path_update_timer >= update_interval:
		nav2d.target_position = target.global_position
		path_update_timer = 0.0
	move_towards_target(delta)
	health_below_zero()
	attack_check()
	process_attack_check(delta)

func stun(duration):
	is_frozen = true
	var anim_players = get_children().filter(func(child):
		return child is AnimationPlayer
	)
	for ap in anim_players:
		ap.playback_active = false  # Pause the animation
	await get_tree().create_timer(duration).timeout
	for ap in anim_players:
		ap.playback_active = true  # Resume the animation
	is_frozen = false

func check_touch():
	if touching_entity and not is_instance_valid(touching_entity):
		touching_entity = null
		touching_player = false
		reached_player = false

func get_target():
	for entity in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(entity):
			continue
		look_at_player()
		var distance = global_position.distance_to(entity.global_position)

		var is_closer = true
		if is_instance_valid(target):
			is_closer = distance < global_position.distance_to(target.global_position)
		
		if entity.has_method("is_alive") and entity.is_alive() and is_closer:
			target = entity
		else:
			target = player_model

func look_at_player():
	if not dead and not independent_look:
			if global_position.x > player_model.global_position.x:
				container.scale.x = abs(container.scale.x)
			else:
				container.scale.x = -abs(container.scale.x)

func random_drop():
	if decay:
		return
	if item_rolled or value == 0:
		return
	item_rolled = true
		
	var ran = randf_range(0, 1)
	if variant == EnemyManager.variant.MONEY:
		ran = 0.0
	if ran <= 0.1:
		value = 1
		if ran <= 0.05:
			value = 5
		if ran <= 0.015:
			value = 10
		var money = MONEY_DROP.instantiate()
		money.global_position = global_position
		money.value = value
		EnemyManager.magnet_all.connect(money._on_magnet_call)
		get_tree().current_scene.add_child(money)
	

func health_below_zero():
	if health <= 0:
		die()

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL, source: String = ""):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)
	
func push_back(strength: float):
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0

func catch_up():
	catchup_timer = 0.0
	if global_position.distance_to(player_model.global_position) >= 1500.0:
		speed = 1000.0
	else:
		speed = base_speed

func start_attack():
	is_attacking = true
	attack_duration = 0.0
	if animation_player.get_animation_list().has("attack"):
		animation_player.play("attack")

func process_attack(delta):
	if unique_attack:
		return
	attack_duration += delta

	if attack_duration >= attack_animation_length and is_attacking:
		if is_instance_valid(touching_entity) and not dead:
			if touching_entity.has_method("take_damage"):
				var knock_direction = touching_entity.global_position - global_position
				var knockback_params = [knock_direction, knockback_strength, trigger_knockback]
				touching_entity.take_damage(damage, armor_penetration, true, knockback_params)
		elif guarantee_hit and not dead:
			var knock_direction = PlayerController.get_player_body().global_position - global_position
			var knockback_params = [knock_direction, knockback_strength, trigger_knockback]
			player.take_damage(damage, armor_penetration, true, knockback_params)
		else:
			touching_entity = null
		guarantee_hit = false
		is_attacking = false
		waiting_after_attack = true
		attack_duration = 0.0
		damage_cooldown = 0.0

func apply_debuff():
	debuff_container.update_debuffs()

func attack_check():
	if unique_attack or spawning: 
		return
	if touching_entity != null and damage_cooldown >= base_attack_speed + 1 and not is_attacking and not dead and not is_frozen:
		start_attack()

func process_attack_check(delta):
	if unique_attack:
		return
	if is_attacking and not dead:
		process_attack(delta)

func move_towards_target(delta):
	if not can_move or unique_movement or spawning:
		return
	# Move toward player only if not waiting after attack
	if player and not is_attacking and post_attack_delay <= 0.01 and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 40.0:
		var next_position = nav2d.get_next_path_position()
		if next_position != Vector2.ZERO:
			global_position = global_position.move_toward(next_position, speed * delta)

func move_towards_target_flying(delta):
	# Move toward player only if not waiting after attack
	if player and not is_attacking and post_attack_delay <= 0.01 and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 40.0:
		var next_position = nav2d.get_next_path_position()
		if next_position != Vector2.ZERO:
			global_position = global_position.move_toward(next_position, speed * delta)

func get_terrain_node():
	return get_tree().get_first_node_in_group("base_terrain")

func get_valid_tile_near_point(pos: Vector2, max_radius: int = 10):
	var terrain_node = get_terrain_node()
	var start_cell = terrain_node.local_to_map(terrain_node.to_local(pos))
	var visited = {}
	var queue: Array[Vector2i] = []
	queue.push_back(start_cell)
	visited[start_cell] = true
	
	var directions := [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
		Vector2i(1, 1),
		Vector2i(-1, -1),
		Vector2i(1, -1),
		Vector2i(-1, 1)
	]
	
	while queue.size() > 0:
		var cell: Vector2i = queue.pop_front()

		var dist = abs(cell.x - start_cell.x) + abs(cell.y - start_cell.y)
		if dist > max_radius:
			continue

		var cell_data = terrain_node.get_cell_tile_data(cell)
		if cell_data and cell_data.get_custom_data("inhabitable"):
			var valid_pos = terrain_node.map_to_local(cell)
			return terrain_node.to_global(valid_pos)

		for d in directions:
			var next = cell + d
			if not visited.has(next):
				visited[next] = true
				queue.push_back(next)

	return Vector2.ZERO

func die():
	random_drop()
	clear_groups()
	damage_batcher.clear_all()
	if is_instance_valid(area_2d):
		for col in area_2d.get_children():
			col.set_deferred("disabled", true)
	EnemyManager.unregister(self)
	extra_death_parameters()
	animation_player.play("die")
	dead = true
	died.emit()
	progress_bar.hide()
	debuff_container.hide()
	shadow.hide()
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _die_from_manager():
	value = 0
	health = 0
	
func clear_groups():
	for group in self.get_groups():
		remove_from_group(group)

func extra_death_parameters():
	pass

func extra_processing(delta):
	pass

func _free_node(anim_name: String):
	if anim_name == "die":
		queue_free()

func _optimize():
	shadow.visible = false
