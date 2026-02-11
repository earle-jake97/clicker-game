extends BaseItem

const item_name = "Moldy Boot"
const item_description = "Gain 35 movement speed."
var tags = ["speed", "stinky"]
var rarity = 1
var item_icon = preload("res://items/icons/moldy_boot.png")
var file_name = "res://items/scripts/1/moldy_boot"
var movement_speed = 35

func get_movement_speed():
	return movement_speed
