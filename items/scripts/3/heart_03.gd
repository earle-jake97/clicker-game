extends BaseItem
var health_percent = 0.60
var tags = ["heal"]
var rarity = 3
var item_name = "Happy Heart"
var item_description = "Heals you for 60% of your max HP."
var item_icon = preload("res://systems/shop/heart2.png")
var file_name = "res://items/scripts/2/heart_03.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func heal():
	player.heal(player.max_hp*health_percent)
