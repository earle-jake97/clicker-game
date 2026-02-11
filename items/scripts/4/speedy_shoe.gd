extends BaseItem

const item_name = "Speedy Shoe"
const item_description = "Gain double your base movement speed. Attacks deal 4% of your movement speed on hit."
var tags = ["speed"]
var rarity = 4
var item_icon = preload("res://items/icons/speedy_shoe.png")
var file_name = "res://items/scripts/4/speedy_shoe"
var movement_speed

func get_movement_speed():
	return player.base_movement_speed

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return
	var damage = player.movement_speed * 0.04
	target.take_damage(damage, DamageBatcher.DamageType.NORMAL, item_name)
