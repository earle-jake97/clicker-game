extends BaseItem
var crit_rate = 0.1
var tags = ["add_crit_rate"]
var rarity = 1
var item_name = "Pointy Sparkles"
var item_description = "Adds 10% crit chance."
var item_icon = preload("res://items/icons/pointy_sparkles.png")
var file_name = "res://items/scripts/1/pointy_sparkles.gd"
func add_to_inventory():
	player.add_item(self)

func get_crit_rate():
	return crit_rate
