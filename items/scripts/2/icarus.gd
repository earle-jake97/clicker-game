extends BaseItem
var dmg_increase = 1
var crit_rate = 0.05
var crit_damage = 0.1
var tags = ["add_damage", "add_crit_rate"]
var rarity = 2
var item_name = "Icarus"
var item_description = "Adds 5 damage and 10% crit chance. You could probably carry with this."
var item_icon = preload("res://items/icons/icarus.png")
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func get_flat_attack_damage():
	return dmg_increase
func get_crit_rate():
	return crit_rate
func get_crit_damage():
	return crit_damage
