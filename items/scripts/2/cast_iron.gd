extends BaseItem

var tags = ["cast_iron"]
var rarity = 2
const item_name = "Cast Iron"
const item_description = "Your attacks have a 5% chance to stun an enemy for 0.2 seconds."
const item_icon = preload("res://items/icons/cast_iron.png")
var file_name = "res://items/scripts/2/cast_iron.gd"
var chance = 0.05
var duration = 0.2

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	var ran = player.calculate_luck()
	if ran <= chance:
		if target.has_method("apply_stun"):
			target.apply_stun(duration)
		
	
