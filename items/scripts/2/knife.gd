extends BaseItem
var dmg_increase = 5
var tags = ["add_damage", "stab"]
var rarity = 2
var item_name = "Knife"
var item_description = "Adds 5 damage to your attacks."
var item_icon = preload("res://items/icons/knife.png")
var file_name = "res://items/scripts/2/knife.gd"
func add_to_inventory():
	player.add_item(self)

func get_flat_attack_damage():
	return dmg_increase
