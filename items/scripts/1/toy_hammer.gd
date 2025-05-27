extends BaseItem
var dmg_increase = 1
var tags = ["add_damage", "bonk"]
var rarity = 1
var item_name = "Toy Hammer"
var item_description = "Adds 1 damage to your attacks."
var item_icon = preload("res://items/icons/toy_hammer.png")
var file_name = "res://items/scripts/1/toy_hammer.gd"
func add_to_inventory():
	player.add_item(self)

func get_flat_attack_damage():
	return dmg_increase
