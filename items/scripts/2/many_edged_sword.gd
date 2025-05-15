extends BaseItem
var dmg_increase = 1
var crit_rate = 0.05
var crit_damage = 0.1
var tags = ["add_damage", "add_crit_rate", "add_crit_damage", "stab"]
var rarity = 2
var item_name = "Many-edged Sword"
var item_description = "Adds 1 damage, 5% crit chance, and 10% crit damage. You could totally carry with this."
var item_icon = preload("res://items/icons/many_edged_sword.png")
var file_name = "res://items/scripts/2/many_edged_sword.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func get_flat_attack_damage():
	return dmg_increase
func get_crit_rate():
	return crit_rate
func get_crit_damage():
	return crit_damage
