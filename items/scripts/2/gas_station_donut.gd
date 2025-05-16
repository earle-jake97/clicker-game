extends BaseItem
var health = 100
var tags = ["flat_max_hp"]
var rarity = 1
var item_name = "Gas Station Donut"
var item_description = "Increases your max HP by 100. "
var item_icon = preload("res://items/icons/gas_station_donut.png")
var file_name = "res://items/scripts/2/gas_station_donut.gd"
func add_to_inventory():
	player.add_item(self)
	heal()

func get_flat_hp():
	return health

func heal():
	player.heal(health)
