extends BaseItem

var amount_of_times_to_click = 2
const item_name = "Clicked Cookie"
const item_description = "Grandma says this will add 2 clicks per second."
var tags = ["timer"]
var rarity = 2
var item_icon = preload("res://items/icons/clicked_cookie.png")
var file_name = "res://items/scripts/2/clicked_cookie.gd"

func add_to_inventory():
	player.add_item(self)

func get_cps():
	for item in player.inventory:
		if item.item_name == "Evil Stopwatch":
			amount_of_times_to_click += 1
	return amount_of_times_to_click
