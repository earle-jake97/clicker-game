extends BaseItem

var tags = ["ice", "ice_cube", "slow"]
var rarity = 2
const item_name = "Ice Cube"
const item_description = "Your attacks will slow down the first enemy hit."
const item_icon = preload("res://items/icons/ice_cube.png")
var file_name = "res://items/scripts/2/ice_cube.gd"
var slow_amount = 0.75 #25% slow

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	# Determine freeze strength
	var strength = 0
	for item in player.inventory:
		if "ice_cube" in item.tags:
			strength += 1

	var final_slow = get_slow_percentage(strength)

func get_slow_percentage(item_count: int, max_slow: float = 0.9, scale: float= 0.5) -> float:
	return max_slow * (1.0 - pow(scale, item_count))
