extends Node2D
class_name BaseEnemy

var is_frozen = false
signal died
var player = PlayerController
var player_model = PlayerController.player
@export var min_speed: float
@export var max_speed: float
var speed: float
@export var damage: int
@export var armor_penetration: int
var health: float
@export var max_health: float
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
var attack_speed
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
	if not dead:
			if global_position.x > player_model.global_position.x:
				container.scale.x = abs(container.scale.x)
			else:
				container.scale.x = -abs(container.scale.x)

func handle_death(delta):
	if dead:
		var color = sprite.modulate
		shadow.visible = false
		color.a = max(color.a - delta * 0.5, 0.0)
		sprite.modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()

func health_below_zero():
	if health <= 0:
		if not paid_out:
			paid_out = true
			player.add_cash(value)
		die()

func die():
	dead = true
	damage_batcher.clear_all()
	progress_bar.hide()
	debuff_container.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	died.emit()

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL, source: String = ""):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)
	
func push_back(strength: float):
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0

func start_attack():
	is_attacking = true
	attack_duration = 0.0

func process_attack(delta):
	attack_duration += delta

	if attack_duration >= attack_animation_length and is_attacking:
		if is_instance_valid(touching_entity) and not dead:
			if touching_entity.has_method("take_damage"):
				touching_entity.take_damage(damage, armor_penetration)
				if touching_entity.has_method("apply_knockback"):
					var knock_direction = touching_entity.global_position - global_position
					touching_entity.apply_knockback(knock_direction, knockback_strength)
		elif guarantee_hit and not dead:
			player.take_damage(damage, armor_penetration)
			var knock_direction = player.global_position - global_position
			player.get_player_body().apply_knockback(knock_direction, knockback_strength)
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
	if touching_entity != null and damage_cooldown >= base_attack_speed + 1 and not is_attacking and not dead and not is_frozen:
		start_attack()

func process_attack_check(delta):
	if is_attacking and not dead:
		process_attack(delta)

func move_towards_target(delta):
	# Move toward player only if not waiting after attack
	if player and not is_attacking and post_attack_delay <= 0.01 and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 40.0:
		
		nav2d.target_position = target.global_position
		
		var next_position = nav2d.get_next_path_position()
		if next_position != Vector2.ZERO:
			global_position = global_position.move_toward(next_position, speed * delta)

func move_towards_target_flying(delta):
	# Move toward player only if not waiting after attack
	if player and not is_attacking and post_attack_delay <= 0.01 and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 40.0:
		
		nav2d.target_position = target.global_position
		
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
