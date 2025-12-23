extends BaseItem

var tags = ["lucky_horseshoe"]
var rarity = 4
var item_name = "Lucky Horseshoe"
var item_description = "Gives the player +1 Luck and negates fall damage."
var item_icon = preload("res://items/icons/golden_horseshoe.png")
var file_name = "res://items/scripts/4/lucky_horseshoe.gd"
var luck = 1
func add_to_inventory():
	player.add_item(self)

func get_luck():
	return luck
