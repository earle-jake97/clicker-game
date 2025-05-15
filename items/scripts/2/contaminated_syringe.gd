extends BaseItem

var tags = []
var rarity = 2
const item_name = "Contaminated Syringe"
const item_description = "Your attacks deal additional damage based on 0.4% of the enemy's current HP."
const item_icon = preload("res://items/icons/contaminated_syringe.png")
var file_name = "res://items/scripts/2/contaminated_syringe.gd"
var health_percentage = 0.004
var occurrences = 0

func proc(target: Node, source_item: BaseItem = null):
	occurrences = 0
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return
	
	for item in PlayerController.inventory:
		if item.item_name == "Contaminated Syringe":
			occurrences += 1
	
	var damage = occurrences * health_percentage * target.health
	target.take_damage(damage)
