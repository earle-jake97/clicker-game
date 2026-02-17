extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
const DEVIL = preload("res://scenes/devil.tscn")
var target_pos
var final_color = Color.SALMON
var speed = 300
var shadow_position = Vector2.ZERO
const SHADOW_SCENE = preload("uid://dfthyp7i3g6to")
var shadow: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var base_color = Color.SALMON
	var red_variation = randf_range(-0.3,0.3)
	var blue_variation = randf_range(-0.2,0.2)
	var green_variation = randf_range(-0.1,0.1)
	final_color = Color(
		clamp(base_color.r + red_variation, 0.0, 1.0),
		clamp(base_color.g + green_variation, 0.0, 1.0),
		clamp(base_color.b + blue_variation, 0.0, 1.0),
	)
	sprite_2d.modulate = final_color
	create_shadow()

func create_shadow():
	shadow = SHADOW_SCENE.instantiate()
	shadow.global_position = shadow_position
	shadow.enemy_ref = self
	get_tree().current_scene.add_child(shadow)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += deg_to_rad(33)
	global_position = global_position.move_toward(target_pos, delta * speed)

	if global_position.distance_to(target_pos) <= 5:
		spawn_devil()

func spawn_devil():
	var enemy = DEVIL.instantiate()
	var sprite = enemy.find_child("sprite", 1, 1)
	enemy.max_health = 40 * PlayerController.difficulty
	enemy.damage = 10
	enemy.armor_penetration = 1
	enemy.value_min = 0
	enemy.value_max = 0
	enemy.min_speed = 100
	enemy.max_speed = 150
	sprite.modulate = final_color
	
	var spawn_pos = global_position
	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
	queue_free()
