extends BaseItem
var health_percent = 0.05
var tags = ["percent_max_hp"]
var rarity = 2
var item_name = "Sus Shroom"
var item_description = "Increases your max HP by 5%. Any area attacks grow in size by 10%."
var item_icon = preload("res://items/icons/sushroom.png")
var file_name = "res://items/scripts/1/sus_shroom.gd"

func add_to_inventory():
	player.add_item(self)

func get_hp_percentage():
	return health_percent
