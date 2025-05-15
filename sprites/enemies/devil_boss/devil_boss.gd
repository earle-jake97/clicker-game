extends Node2D
signal died(enemy_node)
var controller = PlayerController
var player_model = TestPlayer
@onready var minion_ball: Node2D = $sprite/Minion_ball
@onready var animation_player: AnimationPlayer = $sprite/AnimationPlayer
@onready var head: Sprite2D = $sprite/Head_Node/Head
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@onready var health_bar: TextureProgressBar = $ProgressBar
@onready var animation_player_head: AnimationPlayer = $sprite/Head_Node/Head/AnimationPlayer
const DIVING_MINION = preload("res://sprites/enemies/devil/diving_minion.tscn")
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var sprite: Node2D = $sprite
@onready var bleed_label: Label = $"bleed stacks/Label"

@onready var bleed_icon: Sprite2D = $"bleed stacks"
const SHOCKWAVE = preload("res://sprites/enemies/devil_boss/shockwave.tscn")
const HEAD = preload("res://sprites/enemies/devil_boss/head.png")
const HEAD_POG = preload("res://sprites/enemies/devil_boss/head_pog.png")
const HEAD_EYES_CLOSED = preload("res://sprites/enemies/devil_boss/head_eyes_closed.png")
const HEAD_POG_EYES_CLOSED = preload("res://sprites/enemies/devil_boss/head_pog_eyes_closed.png")
const MEDITATE_INTERVAL = 6
const THROW_INTERVAL = 6
const FIREBALL_INTERVAL = 1.5
const MEDITATE_TIME = 2.3
const GLOBAL_INTERVAL = 3.5
const FIREBALL_TRAVEL_TIME = 0.5
const TELEGRAPH = preload("res://scenes/telegraph.tscn")
const FIREBALL = preload("res://sprites/enemies/devil_boss/fireball.tscn")
@onready var shadow: Sprite2D = $sprite/shadow

var debuffs = []

var health = 2000
var max_health = 2000
var bleed_stacks = 0
var dead = false
var paid_out = false
var value = 200
var death_timer = 0.0
var mouth_timer = 0.0
var armor = 50
var meditate_timer = 0.0
var meditating = false


# Called when the node enters the scene tree for the first time.
var attack_cooldown = 0.0
var minion_cooldown = 0.0
var fireball_cooldown = 0.0
var global_cooldown = 0.0
var throw_cooldown = 0.0
var meditate_cooldown = 0.0

var is_attacking = false

func _ready() -> void:
	animation_player.animation_set_next("slam", "idle")
	animation_player.animation_set_next("meditate", "idle")
	animation_player.animation_set_next("throw_minions", "idle")
	bleed_icon.visible = false
	if PlayerController.difficulty >= 15:
		max_health = max_health * pow(1 + 0.10, PlayerController.difficulty)
	else:
		max_health *= controller.difficulty
	health = max_health
	health_bar.visible = false
	health_bar.max_value = max_health
	health_bar.value = health


func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	show_damage_number(amount, damage_type)

func show_damage_number(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	damage_batcher.add_damage(amount, damage_type)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bleed_stacks > 0:
		debuffs.append(debuff.Debuff.BLEED)
		
		bleed_icon.visible = true
		bleed_label.text = "x" + str(bleed_stacks)
	else:
		bleed_icon.visible = false
	mouth_timer += delta
	if health <= max_health/2:
		fireball_cooldown += delta * 2
	elif health <= max_health/4:
		fireball_cooldown += delta * 2.5
	else:
		fireball_cooldown += delta

	throw_cooldown += delta
	meditate_cooldown += delta
	global_cooldown += delta
	meditate_timer += delta
	
	if meditate_timer >= MEDITATE_TIME and meditating:
		bleed_stacks = 0
		health += round(max_health/18.0)
		meditating = false
	
	if not is_attacking and global_cooldown >= GLOBAL_INTERVAL and not dead:
		var ran = randi_range(1,5)
		if ran <= 1 and throw_cooldown >= THROW_INTERVAL:
			throw_minions()
		elif ran <= 2 and bleed_stacks > 0 and meditate_cooldown >= MEDITATE_INTERVAL:
			meditate()
		else:
			slam()
		global_cooldown = 0.0
	
	if dead:
		shadow.visible = false
		var color = modulate
		color.a = max(color.a - delta * 0.5, 0.0)
		modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()

	if health <= 0:
		if not paid_out:
			paid_out = true
			controller.add_cash(value)
		die()
	
	if health < max_health:
		health_bar.visible = true
		
	if fireball_cooldown >= FIREBALL_INTERVAL and not dead:
		fireball_cooldown = 0.0
		shoot_fireball()
	
		# Mouth reset after 0.5s
	if head.texture == HEAD_POG and mouth_timer >= 0.5:
		head.texture = HEAD
	elif head.texture == HEAD_POG_EYES_CLOSED and mouth_timer >= 0.5:
		head.texture = HEAD_EYES_CLOSED
	
	if head.texture == HEAD_EYES_CLOSED and not meditating:
		head.texture = HEAD


func throw_minions():
	throw_cooldown = 0.0
	minion_ball.visible = true
	animation_player.play("throw_minions")
	for i in range(5):
		var enemy = DIVING_MINION.instantiate()
		enemy.target_pos = Vector2(randf_range(550.0, 999),randf_range(300.0, 600))
		enemy.global_position = Vector2(randf_range(550.0, 999), randf_range(-500, -700 ))
		get_tree().current_scene.add_child(enemy)

func shoot_fireball():
	open_mouth()
	var telegraph = TELEGRAPH.instantiate()
	telegraph.damage = 20 + (controller.difficulty * 0.2)
	telegraph.armor_penetration = 0
	telegraph.duration = FIREBALL_TRAVEL_TIME
	if dead:
		telegraph.duration = FIREBALL_TRAVEL_TIME * 2.5
	var chosen_position = player_model.global_position
	telegraph.global_position = chosen_position
	get_tree().current_scene.add_child(telegraph)
	
	var projectile = FIREBALL.instantiate()
	projectile.start_pos = head.global_position
	projectile.target_pos = chosen_position
	projectile.flight_time = FIREBALL_TRAVEL_TIME
	if dead:
		projectile.flight_time = FIREBALL_TRAVEL_TIME * 2.5
	projectile.global_position = head.global_position - Vector2(300, 0)
	get_tree().current_scene.add_child(projectile)

func open_mouth():
	if meditating:
		head.texture = HEAD_POG_EYES_CLOSED
	else:
		head.texture = HEAD_POG
		
	mouth_timer = 0.0

func meditate():
	meditate_timer = 0.0
	head.texture = HEAD_EYES_CLOSED
	meditating = true
	animation_player.play("meditate")
	meditate_cooldown = 0.0

func slam():
	animation_player.play("slam")
	var ran = controller.position_map[randi_range(1,3)].global_position
	var shockwave = SHOCKWAVE.instantiate()
	add_child(shockwave)
	shockwave.chosen_pos = ran
	shockwave.global_position = Vector2(2000, ran.y)
	shockwave.z_index = shockwave.global_position.y
	

func die():
	bleed_icon.visible = false
	head.texture = HEAD_POG_EYES_CLOSED
	animation_player_head.pause()
	health_bar.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()
