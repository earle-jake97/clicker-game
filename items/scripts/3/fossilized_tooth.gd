extends BaseItem

const item_name = "Fossilized Tooth"
const item_description = "Deals 5 damage on hit."
var tags = []
var rarity = 3
var item_icon = preload("res://items/icons/fossilized_tooth.png")
var file_name = "res://items/scripts/3/fossilized_tooth"
var damage = 5

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return
	target.take_damage(damage, DamageBatcher.DamageType.NORMAL, "Fossilized Tooth")
