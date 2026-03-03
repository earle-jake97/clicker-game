extends BaseEnemy
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const SMOKE_CLOUD = preload("res://items/misc/smoke_cloud.tscn")

@onready var head: Sprite2D = $container/sprite/head
@export var projectile_scene: PackedScene = preload("res://scenes/mad projectile.tscn")
@export var telegraph_scene: PackedScene = preload("res://scenes/telegraph.tscn")
var shot_precision = 100.0
const HEAD_SPIT = preload("res://sprites/enemies/toss_devil/head spit.png")
const HEAD = preload("res://sprites/enemies/toss_devil/head.png")
const HEAD_DEAD = preload("res://sprites/enemies/toss_devil/head_dead.png")
const HEAD_SMILE = preload("res://sprites/enemies/toss_devil/head_smile.png")
var player_controller = PlayerController
var attack_timer := 0.0
var chosen_position
var velocity = Vector2.ZERO
var spitting = false
var hopping = true
var previous_debuffs = []
var hop_cooldown = 5.0
var hop_timer = 0.0
var random_hop_timer = 0.0
var random_hop_time = randf_range(5.0, 12.0)

var spit_timer = 0.0
@onready var tween := get_tree().create_tween()


# Called when the node enters the scene tree for the first time.
func extra_ready():
	animation_player.animation_set_next("throw", "idle")
	animation_player.animation_set_next("jump", "idle")
	animation_player.animation_set_next("jump_away", "jump")
	base_speed = 0.0
	damage = 20
	max_health = 450.0
	can_move = false
	base_attack_speed = 1.5
	attack_speed = base_attack_speed
	hop()

func extra_processing(delta):
	look_at_player()
	
	hop_timer -= delta
	random_hop_timer += delta

	if (hop_timer <= 0.0 and check_distance()) or (random_hop_timer >= random_hop_time) and not dead:
		hop_timer = hop_cooldown
		random_hop_timer = 0.0
		random_hop_time = randf_range(5.0, 20.0)
		hop_away()
	if spit_timer >= 0.2 and spitting:
		spitting = false
		spit_timer += delta
	attack_timer += delta
	if attack_timer >= attack_speed and not dead and not is_frozen:
		attack_timer = 0.0
		launch_projectile()
		
func extra_death_parameters():
	head.texture = HEAD_DEAD

func launch_projectile():
	if hopping:
		return
	spit_timer = 0.0
	spitting = true
	animation_player.play("throw")
	head.texture = HEAD_SPIT
	chosen_position = player_model.global_position + Vector2(randf_range(-shot_precision, shot_precision), randf_range(-shot_precision, shot_precision))
	var projectile = projectile_scene.instantiate()
	projectile.start_pos = global_position + Vector2(30, -100)
	projectile.target_pos = chosen_position
	projectile.global_position = global_position
	projectile.chosen_area = chosen_position
	projectile.knockback_strength = 700
	projectile.damage = 20
	get_tree().current_scene.add_child(projectile)
	await get_tree().create_timer(0.1).timeout
	head.texture = HEAD

func hop_away():
	hopping = true
	animation_player.play("jump_away")
	await animation_player.animation_changed
	hop()

func hop():
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return

	var screen_size := get_viewport().get_visible_rect().size

	var margin = 5  # how far inside the screen border to spawn

	# ellipse radii INSIDE screen borders
	var rx = screen_size.x / 2 - margin
	var ry = screen_size.y / 2 - margin

	var angle := randf() * TAU
	var center = player_model.global_position

	var spawn_pos := Vector2(
		center.x + cos(angle) * rx,
		center.y + sin(angle) * ry
	)
	if SoundManager.thrower_spawn_sound():
		audio_stream_player_2d.play()
	global_position = EnemyManager.get_valid_tile_near_point(spawn_pos, 10)
	await animation_player.animation_finished
	hopping = false

func check_distance():
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return false
	var screen_size = get_viewport().get_visible_rect().size
	var half = screen_size / 2
	
	var buffer = 500
	
	var center = player_model.global_position
	var dx = abs(global_position.x - center.x)
	var dy = abs(global_position.y - center.y)
	
	return (dx > half.x + buffer or dy > half.y + buffer)
