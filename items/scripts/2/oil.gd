extends BaseItem

var tags = ["debuff"]
var rarity = 2
const item_name = "Oil"
const item_description = "Step 2, cover your enemies in oil. When you hit an enemy, they are given the oil debuff. If they die, they will explode for 5% of their max HP."
const item_icon = preload("res://items/icons/oil.png")
var file_name = "res://items/scripts/2/oil.gd"
static var explosion_damage = 0.01
static var flat_damage = 5


func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	# Determine explosion strength
	var strength = 0
	for item in player.inventory:
		if "Oil" == item.item_name:
			strength += 1
	var damage = get_explosion_percentage(strength, 0.5)
	if not target.debuffs.has(debuff.Debuff.OIL):
		target.debuffs.append(debuff.Debuff.OIL)
		target.set_meta("oil_applied", true)
		target.apply_debuff()


static func get_explosion_percentage(item_count: int, scale: float= 0.5) -> float:
	return explosion_damage * (1.0 - pow(scale, item_count))

static func get_explosion_damage(enemy, percentage):
	return (enemy * percentage) + flat_damage
