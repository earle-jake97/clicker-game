extends BaseEnemy
signal died(enemy_node)
var controller = PlayerController
var player_model = TestPlayer
@onready var debuff_container: HBoxContainer = $debuff_container
@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@onready var health_bar: TextureProgressBar = $ProgressBar
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var sprite: Node2D = $sprite
const TELEGRAPH = preload("res://scenes/telegraph.tscn")
const ZOMBIE = preload("res://sprites/enemies/zombie/zombie.tscn")
const LIGHTNING_ATTACK = preload("res://sprites/enemies/evil_wizard/lightning_attack.tscn")
const WALL_FIRE_DUO = preload("res://sprites/enemies/evil_wizard/wall_fire_duo.tscn")
const MAGIC_MISSILE = preload("res://sprites/enemies/evil_wizard/magic_missile.tscn")
@onready var cast_origin: Marker2D = $sprite/wand/cast_origin

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shadow: Sprite2D = $shadow
@export var zombie_count = 5
var debuffs = []
var previous_debuffs = []

@export var health = 2000
var max_health = 2000
var bleed_stacks = 0
var dead = false
var paid_out = false
var value = 200
var death_timer = 0.0
var armor = 50
var attacking = false

var firewall_duration = 0.0
var firewall_full_cast = 0.0

# Called when the node enters the scene tree for the first time.
var attack_cooldown = 1.81
var attack_timer = 0.0
var zombie_cooldown = 7.0
var zombie_timer = 0.0
var lightning_cooldown = 5.0
var lightning_timer = 0.0
var firewall_cooldown = 15.0
var firewall_timer = 0.0
var global_timer = 0.0
var global_cooldown = 4.0
var choose_position_timer = 0.0
var choose_position_location = Vector2(0,0)
var last_position = null

var is_attacking = false

func _ready() -> void:
	animation_player.animation_set_next("basic_attack", "idle")
	animation_player.animation_set_next("lightning_attack", "idle")
	animation_player.animation_set_next("raise_zombie", "idle")
	if PlayerController.difficulty >= 15:
		max_health = max_health * pow(1 + 0.12, PlayerController.difficulty)
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
	z_index = global_position.y
	zombie_timer += delta
	firewall_timer += delta
	lightning_timer += delta
	global_timer += delta
	firewall_duration += delta
	firewall_full_cast += delta
	choose_position_timer += delta
	attack_timer += delta
	
	if attack_timer >= attack_cooldown and not attacking:
		attack_timer = 0.0
		animation_player.play("basic_attack")
		shoot_magic_missile()
	
	if attacking:
		firewall()
	
	if choose_position_timer >= 2.0:
		choose_position_timer = 0
		firewall_duration = -0.33
		get_new_random_pos()
	
	if global_timer >= global_cooldown and not attacking:
		global_timer = 0.0
		var available_attacks = []

		if zombie_timer >= zombie_cooldown:
			available_attacks.append("zombies")
		if lightning_timer >= lightning_cooldown:
			available_attacks.append("lightning")
		if firewall_timer >= firewall_cooldown:
			available_attacks.append("firewall")

		if available_attacks.size() > 0:
			var chosen = available_attacks.pick_random()
			match chosen:
				"zombies":
					raise_zombies()
				"lightning":
					lightning_strike()
				"firewall":
					animation_player.play("firewall")
					attacking = true
					firewall_full_cast = 0.0
					firewall_duration = 0.0
			
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


func die():
	debuff_container.hide()
	health_bar.hide()
	remove_from_group("enemy")
	animation_player.play("die")
	dead = true
	died.emit()

func apply_debuff():
	debuff_container.update_debuffs()

func lightning_strike():
	animation_player.play("lightning_attack")
	lightning_timer = 0.0
	var lightning = LIGHTNING_ATTACK.instantiate()
	var ran = controller.position_map[randi_range(0,controller.position_map.size()-1)].global_position
	lightning.damage = 30
	lightning.global_position = ran
	get_tree().current_scene.add_child(lightning)


func raise_zombies():
	animation_player.play("raise_zombie")
	zombie_timer = 0.0
	for i in range(zombie_count):
		set_up_zombie()
	
func set_up_zombie():
	var zombie = ZOMBIE.instantiate()
	zombie.global_position = global_position + Vector2(randf_range(-400.0, 100.0), randf_range(-200.0, 200.0))
	zombie.z_index = zombie.global_position.y
	await get_tree().create_timer(randf_range(0.2, 2.3)).timeout
	get_tree().current_scene.add_child(zombie)

func firewall():
	firewall_timer = 0.0
	if firewall_duration >= 0.1:
		firewall_duration = 0.0
		spawn_fire_duo(choose_position_location)
	if firewall_full_cast >= 10.0:
		attacking = false
		animation_player.play("idle")

func shoot_magic_missile():
	await get_tree().create_timer(0.18).timeout
	var telegraph = TELEGRAPH.instantiate()
	telegraph.damage = 20 + (controller.difficulty * 0.2)
	telegraph.armor_penetration = 0
	telegraph.duration = 1.0
	var chosen_position = player_model.global_position
	telegraph.global_position = chosen_position
	get_tree().current_scene.add_child(telegraph)
	var projectile = MAGIC_MISSILE.instantiate()
	projectile.start_pos = cast_origin.global_position
	projectile.target_pos = chosen_position
	projectile.flight_time = 1.3
	get_tree().current_scene.add_child(projectile)

func spawn_fire_duo(fire_position):
	attack_timer = -2.0
	lightning_timer = -2.0
	var flames = WALL_FIRE_DUO.instantiate()
	flames.global_position = fire_position + Vector2(1250, 250)
	get_tree().current_scene.add_child(flames)

func get_new_random_pos():
	var ran = controller.position_map[randi_range(0,controller.position_map.size()-1)].global_position
	if ran == last_position:
		get_new_random_pos()
	else:
		choose_position_location = ran
		last_position = choose_position_location
