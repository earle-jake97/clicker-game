extends BaseEnemy


signal died
var player = PlayerController
@export var min_speed: float
@export var max_speed: float
var speed: = 50
@export var damage: int
@export var armor_penetration: int
var health: float
@export var max_health: float
@onready var health_bar: TextureProgressBar = $ProgressBar
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@onready var debuff_container: HBoxContainer = $debuff_container
@export var value_min: int
@export var value_max: int
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var shadow: Sprite2D = $shadow
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $sprite

const EYEBALL = preload("res://sprites/enemies/eyeball/eyeball.png")
const EYEBALL_ATTACK = preload("res://sprites/enemies/eyeball/eyeball2.png")

const EYEBALL_PROJECTILE = preload("res://sprites/enemies/eyeball/eyeball_projectile.tscn")
var debuffs = []

var bleed_stacks = 0
var post_attack_delay = 0.0
var death_timer = 0.0
var dead = false
var paid_out = false
var value = 0
var push_strength = 0.0
var pushback_length = 2.0
var pushback_timer = 0.0
var is_pushed = false
var is_attacking = false
var attack_cooldown = 5.0
var attack_timer = 3.0

func _ready() -> void:
	animation_player.animation_set_next("attack", "float")
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health

func _process(delta: float) -> void:
	attack_timer += delta
	
	if attack_timer >= attack_cooldown and not is_attacking:
		attack()
	
	if is_pushed:
		global_position = global_position.move_toward(Vector2(40000, global_position.y), push_strength * 100 * delta)
	pushback_timer += delta
	if pushback_timer >= pushback_length:
		is_pushed = false

	if dead:
		var color = sprite.modulate
		shadow.visible = false
		color.a = max(color.a - delta * 0.5, 0.0)
		sprite.modulate = color
		death_timer += delta
		if death_timer >= 2:
			queue_free()

	if health < max_health:
		health_bar.visible = true

	# Move toward player only if not waiting after attack
	if player and not is_attacking and not dead and not is_pushed and not is_frozen:
		global_position = global_position.move_toward(player.player.global_position + Vector2(400, 0), speed * delta)

	if health <= 0:
		if not paid_out:
			paid_out = true
			player.add_cash(value)
		die()

	z_index = round(global_position.y)


func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)
	
func push_back(strength: float):
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0

func attack():
	is_attacking = true
	if not dead:
		sprite.texture = EYEBALL_ATTACK
		animation_player.play("attack")
	is_attacking = true
	await get_tree().create_timer(0.1667).timeout
	if not dead:
		fire_projectile()
	await get_tree().create_timer(0.3333).timeout
	if not dead:
		fire_projectile()
	await get_tree().create_timer(0.3).timeout
	if not dead:
		fire_projectile()
	is_attacking = false
	attack_timer = 0.0
	await get_tree().create_timer(0.2).timeout
	sprite.texture = EYEBALL

func fire_projectile():
	var projectile = EYEBALL_PROJECTILE.instantiate()
	projectile.global_position = global_position + Vector2(-30, -125)
	get_tree().current_scene.add_child(projectile)

func die():
	sprite.texture = EYEBALL_ATTACK
	progress_bar.hide()
	debuff_container.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()

func apply_debuff():
	debuff_container.update_debuffs()
