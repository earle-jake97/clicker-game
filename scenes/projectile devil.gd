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
@onready var limbs: AnimationPlayer = $limbs
@onready var sprite: Node2D = $sprite
@onready var shadow: Sprite2D = $shadow

@onready var head: Sprite2D = $sprite/head
@export var max_health: float
@onready var health_bar: TextureProgressBar = $ProgressBar
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@onready var player_positions = []
@export var projectile_scene: PackedScene = preload("res://scenes/mad projectile.tscn")
@export var telegraph_scene: PackedScene = preload("res://scenes/telegraph.tscn")
@export var damage: int
@export var armor_penetration: int
@export var value_min: int
@export var value_max: int
var death_timer = 0.0
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
var moving = true
var initial_y
var initial_x
var paid_out = false
var bleed_stacks = 0
var spitting = false
var debuffs = []
var previous_debuffs = []

var spit_timer = 0.0
@onready var tween := get_tree().create_tween()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_speed = base_attack_speed
	shadow.scale = Vector2(0, 0)
	tween.tween_property(shadow, "scale", Vector2(0.22, 0.22), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	attack_speed /= (max(player_controller.difficulty/10, 0.8))
	for node in PlayerController.position_map:
		player_positions.append(node)
		
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(50.0, 100.0)
	for node in get_tree().get_nodes_in_group("player"):
		player = node
	initial_y = global_position.y
	initial_x = player.global_position.x
	value = randi_range(value_min, value_max)
	if SoundManager.thrower_spawn_sound():
		audio_stream_player_2d.play()

func _process(delta: float) -> void:
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
	
	if moving:
		move_forward(delta)

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
	chosen_position = player_positions[randi_range(0, player_positions.size()-1)]
	telegraph.global_position = chosen_position.global_position
	get_tree().current_scene.add_child(telegraph)
	
	var projectile = projectile_scene.instantiate()
	projectile.start_pos = global_position + Vector2(30, -100)
	projectile.target_pos = chosen_position.global_position
	projectile.global_position = global_position
	projectile.chosen_area = chosen_position
	get_tree().current_scene.add_child(projectile)

func move_forward(delta):
	var target = Vector2(initial_x + 800, initial_y) # forward-ish
	var direction = target - global_position
	var distance = direction.length()

	if distance > 1:
		direction = direction.normalized()
		
		var current_speed = 400.0
		
		# Slow down when getting close
		if distance < 100.0:
			current_speed *= distance / 100.0

		velocity = direction * current_speed
		global_position += velocity * delta

		# Stop moving if very close
		if distance < 5.0:
			limbs.play("idle")
			moving = false
			velocity = Vector2.ZERO
	else:
		# Just in case
		limbs.play("idle")
		moving = false
		velocity = Vector2.ZERO
	
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
