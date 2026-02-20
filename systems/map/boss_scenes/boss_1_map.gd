extends Node2D

@onready var boss_spawn: Marker2D = $boss_spawn

const DEVIL_BOSS = preload("res://sprites/enemies/devil_boss/devil_boss.tscn")
const EVIL_WIZARD = preload("res://sprites/enemies/evil_wizard/evil_wizard.tscn")
const MapView = "res://map/map_scene.tscn"
@onready var marker_2d_2: Marker2D = $Positions/Marker2D2

var boss
var can_process = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var rand = randf()
	var rand = 0.1
	if rand <= 0.3:
		boss = DEVIL_BOSS.instantiate()
	else:
		boss = EVIL_WIZARD.instantiate()
	boss.global_position = boss_spawn.global_position
	boss.damage = 20
	boss.health = 2500
	boss.add_to_group("boss")
	boss.died.connect(_on_boss_died)
	get_node("y_sort_node").add_child(boss)
	HealthBar.button.visible = true
	HealthBar.fast_forward = false
	

func _on_boss_died():
	await get_tree().create_timer(2.0).timeout
	GameState.endless_mode = true
	HealthBar.endless_sprite.visible = true
	var rand = randf()
	SceneManager.switch_to_scene(MapView)
