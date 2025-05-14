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
const PROJECTILE_DEMON = preload("res://scenes/projectile_demon.tscn")
const DEVIL = preload("res://scenes/devil.tscn")
const IMP = preload("res://scenes/enemies/imp.tscn")

var player_controller = PlayerController
var spawn_cap
var spawn_timer := 0.0
var next_spawn_time = 1.0
var spawn_count = 0
var all_enemies_spawned = false
var decayRate = 0.07;

func _ready() -> void:
	if GameState.endless_mode:
		decayRate = 0.2
	var difficulty = PlayerController.difficulty
	var spawn_threshold = 0.05
	min_spawn_time = min_spawn_time * pow(1 - decayRate, difficulty);
	max_spawn_time = max_spawn_time * pow(1 - decayRate, difficulty)
	if enemy_scene == DEVIL:
		if difficulty >= 15:
			enemy_max_health = enemy_max_health * pow(1 + 0.10, difficulty)
		else:
			enemy_max_health += difficulty * 4
		min_spawns = max(difficulty * 15, max_spawns)
		max_spawns = min_spawns + randi_range(0, 5) 
	if enemy_scene == PROJECTILE_DEMON:
		min_spawns = max(1, round(difficulty/2.0))
		if difficulty >= 15:
			enemy_max_health = enemy_max_health * pow(1 + 0.10, difficulty)
		else:
			enemy_max_health += difficulty * 20
		max_spawns = min_spawns
	if enemy_scene == IMP:
		if difficulty <= 2:
			min_spawns = 0
			max_spawns = 0
		else:
			if difficulty >= 15:
				enemy_max_health = enemy_max_health * pow(1 + 0.10, difficulty)
			else:
				enemy_max_health += difficulty * 4
			min_spawns = max(difficulty * 3, max_spawns)
			min_spawns + randi_range(0, 3) 
	
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
	var sprite = enemy.get_node("sprite")
	enemy.max_health = enemy_max_health
	enemy.damage = enemy_damage
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
		var red_variation = randf_range(-0.3,0.3)
		var blue_variation = randf_range(-0.2,0.2)
		var green_variation = randf_range(-0.1,0.1)
		var final_color = Color(
			clamp(base_color.r + red_variation, 0.0, 1.0),
			clamp(base_color.g + green_variation, 0.0, 1.0),
			clamp(base_color.b + blue_variation, 0.0, 1.0),
		)
		sprite.modulate = final_color
	
	var spawn_pos = global_position
	spawn_pos.y += randf_range(y_min, y_max)
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
	spawn_count += 1

func check_level_finished():
	if all_enemies_spawned:
		return true
