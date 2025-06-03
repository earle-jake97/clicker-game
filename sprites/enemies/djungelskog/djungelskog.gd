extends BaseEnemy
var damage_accumulated = 0
var total_damage = 0
var debuffs = []
@onready var debuff_container: HBoxContainer = $debuff_container
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var cum_damage: Label = $cum_damage
const MONEY_PARTICLE = preload("res://systems/money_particle.tscn")
const DAMAGE_THRESHOLD = 20.0
@onready var sprite_2d: Sprite2D = $Sprite2D
var max_health = 500
var health = 500
var bleed_stacks = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_health = max_health * PlayerController.difficulty


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cum_damage.text = str(format_large_number(total_damage))
	if damage_accumulated >= DAMAGE_THRESHOLD:
		damage_accumulated -= DAMAGE_THRESHOLD
		PlayerController.add_cash(1)
		spawn_money()

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL):
	damage_accumulated += amount
	total_damage += amount
	if amount < 50:
		animation_player.play("hit")
	if amount >= 50:
		animation_player.play("hit_hard")
	if amount >= 250:
		animation_player.play("hit_very_hard")

func format_large_number(number: int) -> String:
	var suffixes = ["", "k", "m", "b", "t", "q", "Q", "s", "S", "o", "n", "d"]
	var magnitude = 0
	var num = float(number)

	while num >= 1000.0 and magnitude < suffixes.size() - 1:
		num /= 1000.0
		magnitude += 1

	var formatted = "%.2f" % num
	if formatted.ends_with(".00"):
		formatted = formatted.left(formatted.length() - 3)
	elif formatted.ends_with("0"):
		formatted = formatted.left(formatted.length() - 1)

	return formatted + suffixes[magnitude]

func spawn_money():
	var money = MONEY_PARTICLE.instantiate()
	money.global_position = sprite_2d.global_position + Vector2(-50, 0)
	get_tree().current_scene.add_child(money)
