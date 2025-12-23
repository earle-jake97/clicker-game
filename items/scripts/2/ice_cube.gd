extends BaseItem

var tags = ["ice", "ice_cube", "slow"]
var rarity = 2
const item_name = "Ice Cube"
const item_description = "Your attacks will slow down the first enemy hit by 50%."
const item_icon = preload("res://items/icons/ice_cube.png")
var file_name = "res://items/scripts/2/ice_cube.gd"
var slow_amount = 0.50 #50% slow

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	if "speed" in target and "base_speed" in target:
		target.speed = target.base_speed * slow_amount
	if "attack_speed" in target and "base_attack_speed" in target:
		target.attack_speed = target.base_attack_speed * slow_amount
	if not target.debuffs.has(debuff.Debuff.CHILL):
		target.debuffs.append(debuff.Debuff.CHILL)
		target.apply_debuff()
