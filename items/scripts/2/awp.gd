extends BaseItem
const item_name = "Amazing Weapon of Power"
const item_description = "Every 5 seconds, snipe the enemy with the highest health pool for 5x damage. Subsequent collections increase the damage multiplier."
const item_icon = preload("res://items/icons/amazing_weapon_of_power.png")
const tags = ["timer"]
const rarity = 2
var file_name = "res://items/scripts/2/awp.gd"
var occurrences = 1
var player_body = TestPlayer

var cooldown_timer := 0.0
var cooldown := 5.0 
var delay_between_shots = 0

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
	var strongest_enemy = Node2D
	occurrences = 0
	for item in PlayerController.inventory:
		if item.item_name == "Amazing Weapon of Power":
			occurrences += 1
	if not get_tree().get_nodes_in_group("enemy").size() > 0:
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.max_health > max_hp:
			max_hp = enemy.max_health
			strongest_enemy = enemy
	PlayerController.attack_specific_enemy(strongest_enemy, 5 * occurrences)
