extends BaseItem
var dmg_increase = 5
var crit_rate = 0.1
var tags = ["add_damage", "add_crit_rate"]
var rarity = 3
var item_name = "Icarus"
var item_description = "Adds 5 damage and 10% crit chance. A weapon of incredible power that is difficult for even the strongest of warriors to control."
var item_icon = preload("res://items/icons/icarus.png")
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func get_flat_attack_damage():
	return dmg_increase
func get_crit_rate():
	return crit_rate
