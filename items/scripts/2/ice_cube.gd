extends BaseItem

var tags = ["ice", "ice_cube", "slow"]
var rarity = 2
const item_name = "Ice Cube"
const item_description = "Your attacks will slow down the first enemy hit."
const item_icon = preload("res://items/icons/ice_cube.png")
var file_name = "res://items/scripts/2/ice_cube.gd"
var slow_amount = 0.50 #50% slow

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
	var slow = get_slow_percentage(strength, slow_amount, 0.3)
	if "speed" in target and "base_speed" in target:
		target.speed = target.base_speed * (1 - slow)
	if "attack_speed" in target and "base_attack_speed" in target:
		target.attack_speed = target.base_attack_speed * (1 + slow)
	if "sprite" in target and not target.has_meta("ice_cube_slow_applied"):
		target.set_meta("ice_cube_slow_applied", true)
		target.sprite.modulate *= Color(0.3, 0.3, 2.0, 1.0)
		Color.AQUA

func get_slow_percentage(item_count: int, max_slow: float = 0.9, scale: float= 0.5) -> float:
	return max_slow * (1.0 - pow(scale, item_count))
