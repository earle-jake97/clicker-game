extends BaseItem
var health_percent = 0.10
var tags = ["heal"]
var rarity = 1
var item_name = "Tiny heart"
var item_description = "Heals you for 15% of your max HP."
var item_icon = preload("res://systems/shop/heart0.png")
var file_name = "res://items/scripts/1/heart_01.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func heal():
	player.heal(player.max_hp*health_percent)
