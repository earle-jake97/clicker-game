extends BaseEnemy
signal died
@export var speed: float
@export var min_speed: float
@export var max_speed: float
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var debuff_container: HBoxContainer = $debuff_container
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var health: float
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var limbs: AnimationPlayer = $container/limbs
@onready var sprite: Node2D = $container/sprite
@onready var shadow: Sprite2D = $container/shadow
@onready var container: Node2D = $container
@onready var head: Sprite2D = $container/sprite/head
@export var max_health: float
@onready var health_bar: TextureProgressBar = $ProgressBar
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@export var projectile_scene: PackedScene = preload("res://scenes/mad projectile.tscn")
@export var telegraph_scene: PackedScene = preload("res://scenes/telegraph.tscn")
@export var damage: int
@export var armor_penetration: int
@export var value_min: int
@export var value_max: int
var death_timer = 0.0
var shot_precision = 100.0
var dead = false
const HEAD_SPIT = preload("res://sprites/enemies/toss_devil/head spit.png")
const HEAD = preload("res://sprites/enemies/toss_devil/head.png")
const HEAD_DEAD = preload("res://sprites/enemies/toss_devil/head_dead.png")
const HEAD_SMILE = preload("res://sprites/enemies/toss_devil/head_smile.png")
var player = TestPlayer
var player_controller = PlayerController
var value = 0
var attack_timer := 0.0
var base_attack_speed = 1.5
var attack_speed
var chosen_position
var velocity = Vector2.ZERO
var paid_out = false
var bleed_stacks = 0
var spitting = false
var debuffs = []
var previous_debuffs = []

var spit_timer = 0.0
@onready var tween := get_tree().create_tween()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn()
	attack_speed = base_attack_speed
	shadow.scale = Vector2(0, 0)
	tween.tween_property(shadow, "scale", Vector2(0.22, 0.22), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	attack_speed /= (max(player_controller.difficulty/10, 0.8))
		
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(50.0, 100.0)
	value = randi_range(value_min, value_max)
	if SoundManager.thrower_spawn_sound():
		audio_stream_player_2d.play()

func _process(delta: float) -> void:
	look_at_player()
	if spit_timer >= 0.2 and spitting:
		head.texture = HEAD
		limbs.play("idle")
		spitting = false
	spit_timer += delta
	if dead:
		head.texture = HEAD_DEAD
		var color = sprite.modulate
		color.a = max(color.a - delta * 0.5, 0.0)
		sprite.modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()
	
	if health < max_health:
		health_bar.visible = true
	if health <= 0:
		if not paid_out:
			paid_out = true
			player_controller.add_cash(value)
		die()
	z_index = round(global_position.y)

func _physics_process(delta: float) -> void:
	attack_timer += delta
	if attack_timer >= attack_speed and not dead and not is_frozen:
		attack_timer = 0.0
		launch_projectile()

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	show_damage_number(amount, damage_type)

func show_damage_number(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	damage_batcher.add_damage(amount, damage_type)

func launch_projectile():
	spit_timer = 0.0
	spitting = true
	limbs.play("throw")
	head.texture = HEAD_SPIT
	var telegraph = telegraph_scene.instantiate()
	telegraph.damage = 20
	telegraph.armor_penetration = armor_penetration
	chosen_position = player.global_position + Vector2(randf_range(-shot_precision, shot_precision), randf_range(-shot_precision, shot_precision))
	telegraph.global_position = chosen_position
	get_tree().current_scene.add_child(telegraph)
	
	var projectile = projectile_scene.instantiate()
	projectile.start_pos = global_position + Vector2(30, -100)
	projectile.target_pos = chosen_position
	projectile.global_position = global_position
	projectile.chosen_area = chosen_position
	get_tree().current_scene.add_child(projectile)
	
func die():
	died.emit()
	shadow.visible = false
	debuff_container.hide()
	limbs.play("die")
	progress_bar.hide()
	remove_from_group("enemy")
	dead = true

func apply_debuff():
	debuff_container.update_debuffs()
	
func spawn():
	var cam = get_viewport().get_camera_2d()
	if cam == null:
		return

	var screen_size := get_viewport().get_visible_rect().size

	var margin = 5  # how far inside the screen border to spawn

	# ellipse radii INSIDE screen borders
	var rx = screen_size.x / 2 - margin
	var ry = screen_size.y / 2 - margin

	var angle := randf() * TAU
	var center = player.global_position

	var spawn_pos := Vector2(
		center.x + cos(angle) * rx,
		center.y + sin(angle) * ry
	)

	global_position = spawn_pos

func look_at_player():
	if not dead:
			if global_position.x > TestPlayer.global_position.x:
				container.scale.x = abs(container.scale.x)
			else:
				container.scale.x = -abs(container.scale.x)
