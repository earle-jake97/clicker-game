extends BaseEnemy

var damage_accumulated: float = 0.0
var total_damage: float = 0.0

@onready var cum_damage: Label = $cum_damage
@onready var pivot: Marker2D = $container/sprite/pivot

const DAMAGE_THRESHOLD: float = 180.0
const MONEY_PARTICLE = preload("uid://du4i6uerwqj2v")

func configure_enemy() -> void:
	base_move_speed = 0.0
	base_damage = 0
	base_attack_cooldown = 0.0
	base_attack_animation_speed = 1.0
	base_walk_animation_speed = 1.0
	base_max_health = base_max_health * PlayerController.difficulty

	value = 0
	item_rolled = true
	targetable = true
	can_move = false

func should_enter_moving_state() -> bool:
	return false

func should_start_attack() -> bool:
	return false

func enter_state(new_state: EnemyState) -> void:
	match new_state:
		EnemyState.IDLE:
			pass
		EnemyState.DEAD:
			pass

func exit_state(_old_state: EnemyState) -> void:
	pass

func state_idle(_delta: float) -> void:
	pass

func enemy_process(_delta: float) -> void:
	if is_instance_valid(cum_damage):
		cum_damage.text = str(format_large_number(int(total_damage)))

	while damage_accumulated >= DAMAGE_THRESHOLD:
		damage_accumulated -= DAMAGE_THRESHOLD
		PlayerController.add_cash(1)

		for i in range(3):
			spawn_money()

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL, _source: String = "") -> void:
	if dead:
		return

	damage_accumulated += amount
	total_damage += amount

	if amount < 50.0:
		if animation_player.has_animation("hit"):
			animation_player.play("hit")
	elif amount < 250.0:
		if animation_player.has_animation("hit_hard"):
			animation_player.play("hit_hard")
	else:
		if animation_player.has_animation("hit_very_hard"):
			animation_player.play("hit_very_hard")

func format_large_number(number: int) -> String:
	var suffixes = ["", "k", "m", "b", "t", "q", "Q", "s", "S", "o", "n", "d"]
	var magnitude := 0
	var num := float(number)

	while num >= 1000.0 and magnitude < suffixes.size() - 1:
		num /= 1000.0
		magnitude += 1

	var formatted := "%.2f" % num
	if formatted.ends_with(".00"):
		formatted = formatted.left(formatted.length() - 3)
	elif formatted.ends_with("0"):
		formatted = formatted.left(formatted.length() - 1)

	return formatted + suffixes[magnitude]

func spawn_money() -> void:
	var money = MONEY_PARTICLE.instantiate()
	money.z_index = 1000
	money.global_position = sprite.global_position + Vector2(-50, 0)
	get_tree().current_scene.add_child(money)

func die() -> void:
	# Dummy should not really die in normal use, but keep base cleanup if it somehow does.
	super.die()
