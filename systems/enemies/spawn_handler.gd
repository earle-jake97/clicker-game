extends Node2D

@onready var timer: Timer = $Timer
@export var spawn_interval: float = 0.5
var enemy_list: Array
var duplicate_list: Array
var stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_interval = max(0.05, min(1 - 0.05*PlayerController.difficulty, 0.5))
	SpawnManager.set_spawn_handler(self)
	enemy_list = SpawnManager.get_enemies_for_round(PlayerController.difficulty)
	duplicate_list = enemy_list.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stopped:
		timer.stop()
		set_process(false)

func spawn_enemy():
	var spawner_list = SpawnManager.active_spawners
	if spawner_list.is_empty():
		return
	var spawn_pos = spawner_list.pick_random().global_position
	var chosen_enemy = enemy_list.pick_random()
	enemy_list.erase(chosen_enemy)
	var enemy = chosen_enemy.instantiate()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)
	
func stop():
	stopped = true

func _on_timer_timeout() -> void:
	if enemy_list.size() < 1:
		if GameState.timed_room:
			enemy_list = duplicate_list.duplicate()
			timer.start(spawn_interval)
		return  
	spawn_enemy()
	timer.start(spawn_interval)
	
