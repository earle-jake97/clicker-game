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
		enemy_max_health = enemy_max_health * pow(1 + 0.20, difficulty)
	elif difficulty >= 25:
		enemy_max_health = enemy_max_health * pow(1 + 0.14, difficulty)
	elif difficulty >= 15:
		enemy_max_health = enemy_max_health * pow(1 + 0.09, difficulty)
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
	var sprite = enemy.get_node("sprite")
	enemy.max_health = enemy_max_health
	enemy.damage = enemy_damage
	enemy.armor_penetration = enemy_max_armor_penetration
	enemy.value_min = enemy_cash_value_min
	enemy.value_max = enemy_cash_value_max
	enemy.min_speed = enemy_speed - 25
	enemy.max_speed = enemy_speed + 25
	
	var spawn_pos = global_position
	spawn_pos.y += randf_range(y_min, y_max)
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
	spawn_count += 1
