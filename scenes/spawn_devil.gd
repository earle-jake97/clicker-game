extends Node2D

@export var enemy_scene: PackedScene
@export var y_min: float = 300
@export var y_max:float = -100
@export var min_spawns:int = 1
@export var max_spawns:int = 1
@export var min_spawn_time:float
@export var max_spawn_time:float
@export var enemy_max_health: int
@export var enemy_max_armor_penetration: int
@export var enemy_damage: int
@export var enemy_cash_value_min: int
@export var enemy_cash_value_max: int
@export var enemy_speed: int
@export var base_terrain: TileMapLayer
const PROJECTILE_DEMON = preload("res://scenes/projectile_demon.tscn")
const DEVIL = preload("res://scenes/devil.tscn")
const IMP = preload("res://scenes/enemies/imp.tscn")
const ENT = preload("res://scenes/enemies/ent.tscn")
const PROJECTILE_DEMON_ELITE = preload("res://scenes/enemies/projectile_demon_elite.tscn")
const EYEBALL_ENEMY = preload("res://sprites/enemies/eyeball/eyeball_enemy.tscn")


var player_controller = PlayerController
var spawn_cap
var spawn_timer := 0.0
var next_spawn_time = 1.0
var spawn_count = 0
var all_enemies_spawned = false
var decayRate = 0.07;

func _ready() -> void:
	if GameState.endless_mode:
		decayRate = 0.1
	var difficulty = PlayerController.difficulty
	var spawn_threshold = 0.05
	min_spawn_time = min_spawn_time * pow(1 - decayRate, difficulty);
	max_spawn_time = max_spawn_time * pow(1 - decayRate/2, difficulty)
	if enemy_scene == DEVIL:
		min_spawns = max(difficulty * 15, max_spawns)
		max_spawns = min_spawns + randi_range(0, 5) 
	if enemy_scene == PROJECTILE_DEMON:
		min_spawns = max(min_spawns, round(difficulty/2.0))
		max_spawns = min_spawns
	if enemy_scene == PROJECTILE_DEMON_ELITE:
		min_spawns = max(min_spawns, round(difficulty/8.0))
		max_spawns = min_spawns
	if enemy_scene == EYEBALL_ENEMY:
		if difficulty <= 1:
			min_spawns = 0
			max_spawns = 0
		else:
			min_spawns = max(min_spawns, difficulty/2.0)
	if enemy_scene == IMP:
		if difficulty <= 2:
			min_spawns = 0
			max_spawns = 0
		else:
			min_spawns = max(difficulty * 3, max_spawns)
	if enemy_scene == ENT:
		if difficulty <= 5:
			min_spawns = 0
			max_spawns = 0
		else:
			min_spawns = max(difficulty * 1, max_spawns)
	if GameState.endless_counter >= 60:
		enemy_max_health *= pow(1 + 0.5, difficulty)
	elif GameState.endless_counter >= 45:
		enemy_max_health *= pow(1 + 0.3, difficulty)
	elif GameState.endless_counter >= 36:
		enemy_max_health *= pow(1 + 0.14, difficulty)
	elif GameState.endless_counter >= 20:
		enemy_max_health *= pow(1 + 0.092, difficulty)
	elif GameState.endless_counter >= 10:
		enemy_max_health *= pow(1 + 0.04, difficulty)
	else:
		enemy_max_health += difficulty * 3.5
	spawn_cap = randi_range(min_spawns, max_spawns)
	next_spawn_time = randf_range(min_spawn_time, max_spawn_time)

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_count >= spawn_cap:
		all_enemies_spawned = true
	if spawn_timer >= next_spawn_time and spawn_count < spawn_cap:
		spawn_devil()
		spawn_timer = 0.0
		next_spawn_time = randf_range(min_spawn_time, max_spawn_time)

func spawn_devil():
	var enemy = enemy_scene.instantiate()
	var sprite = enemy.find_child("sprite", 1, 1)
	enemy.max_health = enemy_max_health
	enemy.damage = enemy_damage + PlayerController.difficulty * 2
	enemy.armor_penetration = enemy_max_armor_penetration
	enemy.value_min = enemy_cash_value_min
	enemy.value_max = enemy_cash_value_max
	enemy.min_speed = enemy_speed - 25
	enemy.max_speed = enemy_speed + 25
	var rand_value = randi_range(1, 100)
	if rand_value == 1:
		sprite.modulate = Color.GOLD
		enemy.value_min *= 10
		enemy.value_max *= 10
	else:
		var base_color = Color.SALMON
		var red_variation
		var blue_variation
		var green_variation
		if enemy_scene == ENT:
			base_color = Color.DARK_GRAY
			red_variation = randf_range(-0.3,0.3)
			blue_variation = randf_range(-0.3,0.3)
			green_variation = randf_range(-0.3,0.3)
		else:
			red_variation = randf_range(-0.3,0.3)
			blue_variation = randf_range(-0.2,0.2)
			green_variation = randf_range(-0.1,0.1)
		var final_color = Color(
			clamp(base_color.r + red_variation, 0.0, 1.0),
			clamp(base_color.g + green_variation, 0.0, 1.0),
			clamp(base_color.b + blue_variation, 0.0, 1.0),
		)
		sprite.modulate = final_color
	
	var spawn_pos = spawn_position_logic()
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
	spawn_count += 1

func check_level_finished():
	if all_enemies_spawned:
		return true

func spawn_position_logic():
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return

	var screen_size := get_viewport().get_visible_rect().size
	var margin = -300  # how far outside the screen border to spawn

	# ellipse radii INSIDE screen borders
	var rx = screen_size.x / 2 - margin
	var ry = screen_size.y / 2 - margin

	var angle := randf() * TAU
	var center = PlayerController.player.global_position
	var loop = true
	var spawn_pos = Vector2.ZERO
	var increment = 0
	while loop:
		spawn_pos = Vector2(
			center.x + cos(angle) * rx,
			center.y + sin(angle) * ry
		)
		var tilemap_pos = base_terrain.local_to_map(base_terrain.to_local(spawn_pos))
		var cell_data = base_terrain.get_cell_tile_data(tilemap_pos)
		if cell_data and cell_data.get_custom_data("spawnable") == true:
			loop = false
		increment += 1
		if increment >= 20:
			return Vector2.ZERO
			
	return spawn_pos

func get_spawn_cap():
	return spawn_cap
