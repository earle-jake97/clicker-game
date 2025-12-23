extends BaseItem
var health = 10
var health_percent = 0.10
var tags = ["percent_max_hp", "heal", "flat_max_hp"]
var rarity = 2
var item_name = "First Aid Kit"
var item_description = "Increases your max HP by 10. Additionally, adds a 10% multiplier to your max HP."
var item_icon = preload("res://items/icons/first_aid_kit.png")
var file_name = "res://items/scripts/1/first_aid_kit.gd"
func add_to_inventory():
	player.add_item(self)
	heal()

func get_hp_percentage():
	return health_percent

func get_flat_hp():
	return health

func heal():
	player.heal(player.max_hp/2)
