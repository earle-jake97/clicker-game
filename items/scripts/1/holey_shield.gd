extends BaseItem
var health = 30
var armor = 15
var tags = ["armor", "flat_max_hp"]
var rarity = 1
var item_name = "Holey Shield"
var item_description = "Increases your max HP by 30 and armor by 15. "
var item_icon = preload("res://items/icons/holey_shield.png")
var file_name = "res://items/scripts/1/holey_shield.gd"
func add_to_inventory():
	player.add_item(self)
	heal()

func get_flat_hp():
	return health

func get_armor():
	return armor

func heal():
	player.heal(health)
