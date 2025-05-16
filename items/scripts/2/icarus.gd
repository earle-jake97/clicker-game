extends BaseItem
var dmg_increase = 4
var crit_rate = 0.1
var tags = ["add_damage", "add_crit_rate"]
var rarity = 2
var item_name = "Icarus"
var item_description = "Adds 5 damage and 10% crit chance. You could probably carry with this."
var item_icon = preload("res://items/icons/icarus.png")
func add_to_inventory():
	player.add_item(self)

func get_flat_attack_damage():
	return dmg_increase
func get_crit_rate():
	return crit_rate
