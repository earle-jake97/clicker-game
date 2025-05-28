extends BaseItem

var tags = ["cast_iron"]
var rarity = 2
const item_name = "Cast Iron"
const item_description = "Your attacks have a 5% chance to stun an enemy for 1 second."
const item_icon = preload("res://items/icons/cast_iron.png")
var file_name = "res://items/scripts/2/cast_iron.gd"
var chance = 0.05 
var duration = 1.0 

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	# Determine freeze strength
	duration = 0
	for item in player.inventory:
		if "cast_iron" in item.tags:
			duration += 1
	var ran = player.calculate_luck()
	if ran <= 0.1:
		target.stun(duration)
		
	
