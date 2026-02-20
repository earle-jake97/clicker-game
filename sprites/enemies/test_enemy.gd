extends BaseEnemy
@onready var projectile_spawn: Marker2D = $container/projectile_spawn
const EYEBALL = preload("res://sprites/enemies/eyeball/eyeball.png")
const EYEBALL_ATTACK = preload("res://sprites/enemies/eyeball/eyeball2.png")

const EYEBALL_PROJECTILE = preload("res://sprites/enemies/eyeball/eyeball_projectile.tscn")
var attack_cooldown = 5.0
var attack_timer = 3.0

func _ready() -> void:
	if EnemyManager.get_all_enemies().size() >= 50:
		shadow.visible = false
	EnemyManager.optimize.connect(_optimize)
	value = randi_range(value_min, value_max)
	health_bar.visible = false
	health_bar.max_value = max_health
	health = max_health
	health_bar.value = health
	base_speed = speed
	attack_speed = base_attack_speed
	extra_ready()

func _physics_process(delta: float) -> void:
	if health < max_health:
		health_bar.visible = true
	if path_update_timer >= update_interval:
		nav2d.target_position = target.global_position
		path_update_timer = 0.0
	health_below_zero()

func extra_ready():
	unique_attack = true
	unique_movement = true
	animation_player.animation_set_next("attack", "float")
