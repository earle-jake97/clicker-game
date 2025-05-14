extends BaseItem
var health_percent = 0.30
var tags = ["heal"]
var rarity = 2
var item_name = "Healthy Heart"
var item_description = "Heals you for 30% of your max HP."
var item_icon = preload("res://systems/shop/heart1.png")
var file_name = "res://items/scripts/2/heart_02.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func heal():
	player.heal(player.max_hp*health_percent)
