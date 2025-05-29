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
	if difficulty >= 40:
		enemy_max_health *= pow(1 + 0.14, difficulty)
	elif difficulty >= 25:
		enemy_max_health *= pow(1 + 0.10, difficulty)
	elif difficulty >= 15:
		enemy_max_health *= pow(1 + 0.05, difficulty)
	else:
		enemy_max_health *= (difficulty*0.5)
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
	enemy.damage = enemy_damage + PlayerController.difficulty * 2
	enemy.armor_penetration = enemy_max_armor_penetration
	enemy.value_min = enemy_cash_value_min
	enemy.value_max = enemy_cash_value_max
	enemy.min_speed = enemy_speed
	enemy.max_speed = enemy_speed
	var rand_value = randi_range(1, 100)
	if rand_value == 1:
		sprite.modulate = Color.GOLD
		enemy.value_min *= 1
		enemy.value_max *= 1
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
	
	var spawn_pos = global_position
	spawn_pos.y += randf_range(y_min, y_max)
	enemy.global_position = spawn_pos
	enemy.scale *= 2.5 
	get_tree().current_scene.add_child(enemy)
	spawn_count += 1

func check_level_finished():
	if all_enemies_spawned:
		return true
