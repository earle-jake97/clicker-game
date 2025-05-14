extends BaseItem

const item_name = "Siphoning Soul"
const item_description = "Every attack heals you for 0.5% of your max HP."
var tags = ["heal"]
var rarity = 3
var item_icon = preload("res://items/icons/siphoning_soul.png")
var file_name = "res://items/scripts/3/siphoning_soul"
var base_heal_amount = 0.005

func proc(enemy, any):
	var count = 0
	for item in PlayerController.inventory:
		if item.item_name == "Siphoning Soul":
			count += 1
	
	if count > 0:
		var heal_multiplier = (2.0 - pow(2.0, -count))
		var heal_amount = PlayerController.max_hp * base_heal_amount * heal_multiplier
		PlayerController.heal(round(heal_amount))
