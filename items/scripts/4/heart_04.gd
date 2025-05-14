extends BaseItem
var health_percent = 1.0
var tags = ["heal"]
var rarity = 4
var item_name = "Giga Heart"
var item_description = "Heals you for 100% of your max HP."
var item_icon = preload("res://systems/shop/heart3.png")
var file_name = "res://items/scripts/4/heart_04.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func heal():
	player.heal(player.max_hp*health_percent)
