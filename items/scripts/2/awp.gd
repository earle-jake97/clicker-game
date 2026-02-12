extends BaseItem
const item_name = "Amazing Weapon of Power"
const item_description = "Every second, snipe the enemy with the highest health pool. Consecutive shots against the same enemy increase by 20% each shot, up to 400%."
const item_icon = preload("res://items/icons/amazing_weapon_of_power.png")
const tags = ["timer"]
const rarity = 2
var file_name = "res://items/scripts/2/awp.gd"
var occurrences = 1
var player_body = TestPlayer
var multiplier = 1.2

var cooldown_timer := 0.0
var cooldown := 1.0
var delay_between_shots = 0
var last_enemy = -1
var add_damage = 1

func _ready() -> void:
	connect("reset", Callable(self, "queue_free"))

func _process(delta):
	if not player:
		return
	
	delay_between_shots += delta
	
	cooldown_timer += delta
	if cooldown_timer >= cooldown:
		cooldown_timer = 0.0
		shoot()


func shoot():
	var max_hp = 0
	var strongest_enemy: Node2D = null
	occurrences = 1
	
	for item in PlayerController.inventory:
		if item.item_name == "Evil Stopwatch":
			occurrences += 1
	
	var enemies = player.get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return
	
	for enemy in enemies:
		if enemy.max_health > max_hp:
			max_hp = enemy.max_health
			strongest_enemy = enemy
	
	if strongest_enemy == null:
		return
	
	var enemy_id = strongest_enemy.get_instance_id()
	if enemy_id == last_enemy:
		add_damage += 0.1
		if add_damage > 4.0:
			add_damage = 4.0
	else:
		add_damage = 1
	last_enemy = enemy_id
	PlayerController.attack_specific_enemy(strongest_enemy, occurrences * add_damage)
