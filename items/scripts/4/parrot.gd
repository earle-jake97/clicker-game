extends BaseItem

var tags = ["mimic"]
var rarity = 4
const item_name = "Parrot"
const item_description = "50% chance of your item procs triggering a second time."
const item_icon = preload("res://items/icons/parrot.png")
var file_name = "res://items/scripts/4/parrot.gd"

func get_trigger():
	var ran = randi_range(0,1)
	if ran == 0:
		return true
	return false
