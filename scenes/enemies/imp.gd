extends BaseEnemy

signal died
var player = PlayerController
@export var min_speed: float
@export var max_speed: float
var speed: float
@export var damage: int
@export var armor_penetration: int
var health: float
@export var max_health: float
@onready var health_bar: TextureProgressBar = $ProgressBar
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@export var value_min: int
@export var value_max: int
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Node2D = $sprite
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var bleed_icon: Sprite2D = $"bleed stacks"
@onready var bleed_label: Label = $"bleed stacks/Label"
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var shadow: Sprite2D = $shadow
var debuffs = []

var base_attack_speed = 0.7
var bleed_stacks = 0
var damage_cooldown = 0.0
var touching_player = false
var attack_duration = 0.0
var is_attacking = false
var reached_player = false
var post_attack_delay = 0.0
var waiting_after_attack = false
var death_timer = 0.0
var dead = false
var paid_out = false
var value = 0
var base_speed
var attack_speed
var push_strength = 0.0
var pushback_length = 2.0
var pushback_timer = 0.0
var is_pushed = false

func _ready() -> void:
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(min_speed, max_speed)
	base_speed = speed
	attack_speed = base_attack_speed

func _process(delta: float) -> void:
	if is_pushed:
		global_position = global_position.move_toward(Vector2(40000, global_position.y), push_strength * 300 * delta)
	pushback_timer += delta
	
	if pushback_timer >= pushback_length:
		is_pushed = false
	if bleed_stacks > 0:
		bleed_icon.visible = true
		bleed_label.text = "x" + str(bleed_stacks)
		debuffs.append(debuff.Debuff.BLEED)
	if dead:
		var color = sprite.modulate
		shadow.visible = false
		color.a = max(color.a - delta * 0.5, 0.0)
		sprite.modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()
	damage_cooldown += delta

	if health < max_health:
		health_bar.visible = true

	# Handle post-attack delay
	if waiting_after_attack:
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			animation_player.play("move")
				
			post_attack_delay = 0.0

	# Move toward player only if not waiting after attack
	elif player and not is_attacking and not dead and not is_frozen:
		global_position = global_position.move_toward(player.player.global_position, speed * delta)

	if health <= 0:
		if not paid_out:
			paid_out = true
			player.add_cash(value)
		die()

	z_index = round(global_position.y)

	if touching_player and damage_cooldown >= player.iframe_duration and not is_attacking and not dead:
		reached_player = true
		start_attack()

	if is_attacking and not dead:
		process_attack(delta)
func push_back(strength: float):
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0
	
func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)

func start_attack():
	animation_player.play("attack")

	is_attacking = true
	attack_duration = 0.0

func process_attack(delta):
	attack_duration += delta

	if attack_duration >= 0.8666 and is_attacking:
		player.take_damage(damage, armor_penetration)
		is_attacking = false
		waiting_after_attack = true
		attack_duration = 0.0
		damage_cooldown = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = false
		reached_player = false



func die():
	bleed_icon.visible = false
	progress_bar.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()
