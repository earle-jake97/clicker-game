extends BaseItem

var amount_of_times_to_click = 1
const item_name = "Slop"
const item_description = "Prevents your game from crashing due to exhausting the item pool."
var tags = []
var rarity = 1
var item_icon = preload("res://items/icons/slop.png")
var file_name = "res://items/scripts/1/slop.gd"
var dmg_increase = 1
var hp_increase = 10

func get_flat_attack_damage():
	return dmg_increase

func get_flat_hp():
	return hp_increase
