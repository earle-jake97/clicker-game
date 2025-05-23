extends BaseItem
const health_percent = 0.30
const tags = ["heal"]
const rarity = 2
const item_name = "Healthy Heart"
const item_description = "Heals you for 30% of your max HP."
const item_icon = preload("res://systems/shop/heart1.png")
const file_name = "res://items/scripts/2/heart_02.gd"
func add_to_inventory():
	player.add_item(self)

func heal():
	player.heal(player.max_hp*health_percent)
