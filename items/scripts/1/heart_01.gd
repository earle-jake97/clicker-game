extends BaseItem
const health_percent = 0.10
const tags = ["heal"]
const rarity = 1
const item_name = "Tiny heart"
const item_description = "Heals you for 15% of your max HP."
const item_icon = preload("res://systems/shop/heart0.png")
const file_name = "res://items/scripts/1/heart_01.gd"
func add_to_inventory():
	player.add_item(self)

func heal():
	player.heal(player.max_hp*health_percent)
