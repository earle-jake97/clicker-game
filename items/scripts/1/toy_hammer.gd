extends BaseItem
var dmg_increase = 3
var tags = ["add_damage", "bonk"]
var rarity = 1
var item_name = "Toy Hammer"
var item_description = "Adds 3 damage to your attacks."
var item_icon = preload("res://items/icons/toy_hammer.png")
var file_name = "res://items/scripts/1/toy_hammer.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func get_flat_attack_damage():
	return dmg_increase
