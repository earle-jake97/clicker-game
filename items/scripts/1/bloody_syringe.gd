extends BaseItem

var tags = []
var rarity = 1
const item_name = "Bloody Syringe"
const item_description = "Your attacks deal additional damage based on 3% of your max HP. Additionally, gain 10 HP."
const item_icon = preload("res://items/icons/bloody_syringe.png")
var file_name = "res://items/scripts/1/bloody_syringe.gd"
var health_percentage = 0.03
var occurrences = 0
var health = 10

func proc(target: Node, source_item: BaseItem = null):
	occurrences = 0
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return
	
	for item in PlayerController.inventory:
		if item.item_name == "Bloody Syringe":
			occurrences += 1
	
	var damage = occurrences * 0.01 * PlayerController.max_hp
	target.take_damage(damage)

func get_flat_hp():
	return health
