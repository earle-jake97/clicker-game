extends BaseItem
var crit_rate = 0.05
var damage = 2
var tags = ["add_crit_rate", "add_crit_damage"]
var rarity = 1
var item_name = "Pointy Sparkles"
var item_description = "Adds 5% crit chance and 2 damage."
var item_icon = preload("res://items/icons/pointy_sparkles.png")
var file_name = "res://items/scripts/1/pointy_sparkles.gd"
func add_to_inventory():
	player.add_item(self)

func get_crit_rate():
	return crit_rate

func get_flat_attack_damage():
	return damage
