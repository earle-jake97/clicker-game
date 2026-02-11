extends BaseItem

const item_name = "Needles"
const item_description = "Deals 1 damage on hit, 2 damage if the target is bleeding."
var tags = []
var rarity = 1
var item_icon = preload("res://items/icons/needles.png")
var file_name = "res://items/scripts/1/needles"
var damage = 1

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return
	
	if target.bleed_stacks >= 1:
		damage = 2
	target.take_damage(damage, DamageBatcher.DamageType.NORMAL, "Needles")
