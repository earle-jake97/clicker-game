extends BaseItem

var tags = ["execute"]
var rarity = 3
const item_name = "Headtaker"
const item_description = "If this item procs on a target below 8% HP, the target will die."
const item_icon = preload("res://items/icons/headtaker.png")
var file_name = "res://items/scripts/3/headtaker.gd"
var min_threshold = 0.08

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	# Determine freeze strength
	var amount = 0
	for item in player.inventory:
		if "execute" in item.tags:
			amount += 1
	var execute_threshold = get_execute_threshold(amount)
	if "health" in target and "max_health" in target:
		var percentage = target.health / target.max_health
		if percentage <= execute_threshold:
			target.health = 0

func get_execute_threshold(item_count):
	var max_threshold = 0.99
	var scale = 0.05
	return min_threshold + (max_threshold - min_threshold) * (1.0 - exp(-scale * item_count))
