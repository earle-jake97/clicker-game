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
@onready var animation_player: AnimationPlayer = $container/AnimationPlayer
@onready var sprite: Node2D = $container/sprite
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var shadow: Sprite2D = $container/shadow
@onready var debuff_container: HBoxContainer = $debuff_container
@onready var container: Node2D = $container

var debuffs = []
var touching_player = false
var base_attack_speed = 0.7
var damage_cooldown = 0.0
var attack_duration = 0.0
var is_attacking = false
var waiting_after_attack = false
var post_attack_delay = 0.0
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
var target: Node = TestPlayer
var touching_entity: Node = null
var guarantee_hit = false
var reached_player = false


func _ready() -> void:
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	speed = randf_range(min_speed, max_speed)
	base_speed = speed
	attack_speed = base_attack_speed

func _physics_process(delta: float) -> void:
	# Clear invalid target
	if touching_entity and not is_instance_valid(touching_entity):
		touching_entity = null

	# Target selection
	for entity in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(entity):
			continue
		look_at_player()
		var distance = global_position.distance_to(entity.global_position)
		var is_closer = true
		if is_instance_valid(target):
			is_closer = distance < global_position.distance_to(target.global_position)
		if entity.has_method("is_alive") and entity.is_alive() and is_closer and entity.global_position.x <= global_position.x:
			target = entity
		else:
			target = TestPlayer

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

	# Move toward target if not attacking, dead, or pushed
	elif not dead and not is_pushed and not is_frozen:
		if is_instance_valid(target):
			if is_attacking:
				global_position = global_position.move_toward(target.global_position, speed * 0.75 * delta)
			else:
				global_position = global_position.move_toward(target.global_position, speed * delta)

	if health <= 0:
		if not paid_out:
			paid_out = true
			player.add_cash(value)
		die()

	z_index = round(global_position.y)

	# Start attack if touching entity
	if touching_entity and damage_cooldown >= player.iframe_duration and not is_attacking and not dead:
		start_attack()

	if is_attacking and not dead:
		process_attack(delta)

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	health -= amount
	health_bar.value = health
	damage_batcher.add_damage(amount, damage_type)

func push_back(strength: float):
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0

func start_attack():
	if reached_player:
		guarantee_hit = true
	animation_player.play("attack")
	is_attacking = true
	attack_duration = 0.0

func process_attack(delta):
	attack_duration += delta

	if attack_duration >= 0.8666 and is_attacking:
		if is_instance_valid(touching_entity):
			if touching_entity.has_method("take_damage"):
				touching_entity.take_damage(damage, armor_penetration)
		else:
			touching_entity = null
			
		guarantee_hit = false
		is_attacking = false
		waiting_after_attack = true
		attack_duration = 0.0
		damage_cooldown = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = true
		touching_entity = area.get_parent()

	elif area.is_in_group("minion_hitbox"):
		touching_player = false
		touching_entity = area.get_parent()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if touching_entity and area.get_parent() == touching_entity:
		touching_entity = null
		touching_player = false


func die():
	debuff_container.hide()
	progress_bar.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()

func apply_debuff():
	debuff_container.update_debuffs()

func look_at_player():
	if not dead:
		if global_position.x > TestPlayer.global_position.x:
			container.scale.x = abs(container.scale.x)
		else:
			container.scale.x = -abs(container.scale.x)
