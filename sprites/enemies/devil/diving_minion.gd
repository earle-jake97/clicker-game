extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

const DEVIL = preload("uid://ducyvw4p4i56c")
const SHADOW_SCENE = preload("uid://dfthyp7i3g6to")

var target_pos: Vector2
var speed: float = 300.0
var shadow_position: Vector2 = Vector2.ZERO
var shadow: Node2D = null
var health = null
var decay := false

func _ready() -> void:
	create_shadow()

func create_shadow() -> void:
	shadow = SHADOW_SCENE.instantiate()
	shadow.global_position = shadow_position
	shadow.enemy_ref = self
	get_tree().current_scene.get_node("y_sort_node").add_child(shadow)
	shadow.visible = true

func _process(delta: float) -> void:
	rotation += deg_to_rad(33)
	global_position = global_position.move_toward(target_pos, delta * speed)

	if global_position.distance_to(target_pos) <= 5.0:
		spawn_devil()

func spawn_devil() -> void:
	var enemy = DEVIL.instantiate()

	enemy.base_max_health = 40.0 * PlayerController.difficulty
	if health != null:
		enemy.base_max_health = health

	enemy.base_damage = 10
	enemy.base_armor_penetration = 1
	enemy.value_min = 0
	enemy.value_max = 0
	enemy.base_move_speed = 100.0

	var spawn_pos := global_position
	enemy.global_position = spawn_pos
	get_tree().current_scene.get_node("y_sort_node").add_child(enemy)

	if decay and enemy is BaseEnemy:
		var decay_modifier := DecayModifier.new()
		enemy.add_modifier(decay_modifier)

	queue_free()
