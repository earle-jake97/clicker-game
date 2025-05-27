extends BaseItem
var dmg_increase = 5
var percent_attack_damage = 0.1
var tags = ["add_damage"]
var rarity = 4
var item_name = "The Meal"
var item_description = "This tasty treat will give you 5 additional damage, and a 10% damage multiplier!"
var item_icon = preload("res://items/icons/the_meal.png")
var file_name = "res://items/scripts/4/the_meal.gd"
func add_to_inventory():
	player.add_item(self)
	heal()

func get_flat_attack_damage():
	return dmg_increase

func heal():
	player.heal(player.max_hp)

func get_percent_attack_damage():
	return percent_attack_damage
