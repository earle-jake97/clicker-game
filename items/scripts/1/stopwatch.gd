extends BaseItem

var amount_of_times_to_click = 1
const item_name = "Stopwatch"
const item_description = "Adds one extra hit per second."
var tags = ["timer"]
var rarity = 1
var item_icon = preload("res://items/icons/stopwatch.png")
var file_name = "res://items/scripts/1/stopwatch.gd"

func add_to_inventory():
	player.add_item(self)

func get_cps():
	amount_of_times_to_click = 1
	for item in player.inventory:
		if item.item_name == "Evil Stopwatch":
			amount_of_times_to_click += 1
	return amount_of_times_to_click
