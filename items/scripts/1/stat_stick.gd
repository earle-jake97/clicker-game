extends BaseItem
var health = 1
var armor = 1
var health_percent = 0.01
var dmg_increase = 1
var crit_rate = 0.01
var crit_damage = 0.01
var percent_attack_damage = 0.01
var tags = ["armor", "flat_max_hp", "percent_max_hp", "heal", "add_damage", "add_crit_rate", "add_crit_damage"]
var rarity = 1
var item_name = "Stat Stick"
var item_description = "Increases almost every stat by 1."
var item_icon = preload("res://items/icons/stat_stick.png")
var file_name = "res://items/scripts/1/stat_stick.gd"
func add_to_inventory():
	player.add_item(self)
	print("Added " + self.name + " to inventory.")

func get_flat_hp():
	return health

func get_armor():
	return armor

func get_flat_attack_damage():
	return dmg_increase

func get_hp_percentage():
	return health_percent

func get_crit_rate():
	return crit_rate

func get_crit_damage():
	return crit_damage

func heal():
	player.heal(player.base_max_hp * health_percent + health)

func get_percent_attack_damage():
	return percent_attack_damage
