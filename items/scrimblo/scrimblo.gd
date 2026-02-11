extends Node2D
var health = 100
var max_hp = 100
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var death_timer = 0.0
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var shadow: Sprite2D = $shadow
const SCRIMBLO_PROJECTILE = preload("res://items/scrimblo/scrimblo_projectile.tscn")
var projectile_cooldown
var projectile_timer = 0.0
var tree
@onready var mouth: Marker2D = $mouth
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var decay_timer = 0.0
var health_percentage


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.scene_switched.connect(queue_free)
	progress_bar.value = health
	health = max_hp
	progress_bar.max_value = max_hp
	projectile_cooldown = PlayerController.clicks_per_second * 0.3333333
	health_percentage = max_hp / 50.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	decay_timer += delta
	if decay_timer >= 0.2:
		decay_timer = 0.0
		health -= health_percentage
	
	projectile_timer += delta
	if health < max_hp and is_alive():
		progress_bar.visible = true
	z_index = global_position.y
	progress_bar.value = health
	if health <= 0:
		animated_sprite_2d.play("die")
		shadow.visible = false
		collision_shape_2d.disabled = true
		progress_bar.visible = false
		animation_player.play("die")
		death_timer += delta
	if death_timer >= 1.0:
		queue_free()
	if projectile_timer >= projectile_cooldown:
		projectile_timer = 0.0
		shoot_projectile()

func take_damage(damage, pen):
	health -= damage

func is_alive():
	if health > 0:
		return true
	else:
		return false

func shoot_projectile():
	var proj = SCRIMBLO_PROJECTILE.instantiate()
	var target = get_closest_enemy()
	if not is_instance_valid(target):
		return
	var direction = ((target.global_position + Vector2(0, -50)) - mouth.global_position).normalized()
	proj.global_position = mouth.global_position
	proj.direction = direction
	get_tree().current_scene.add_child(proj)

func get_closest_enemy():
	var closest_enemy = null
	var shortest_distance = INF
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy and enemy.is_inside_tree():
			var distance = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = enemy
	return closest_enemy
