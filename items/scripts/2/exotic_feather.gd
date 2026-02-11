extends BaseItem

const item_name = "Exotic Feather"
const item_description = "Gain 100 movement speed."
var tags = ["speed"]
var rarity = 2
var item_icon = preload("res://items/icons/exotic_feather.png")
var file_name = "res://items/scripts/2/exotic_feather"
var movement_speed = 100

func get_movement_speed():
	return movement_speed
