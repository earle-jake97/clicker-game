extends BaseItem

var tags = []
var rarity = 1
const item_name = "Bloody Syringe"
const item_description = "Your attacks deal additional damage based on 3% of your max HP. Additionally, gain 10 HP."
const item_icon = preload("res://items/icons/bloody_syringe.png")
var file_name = "res://items/scripts/1/bloody_syringe.gd"
var health_percentage = 0.03
var health = 10

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return
	
	var damage = health_percentage * PlayerController.max_hp
	target.take_damage(damage, DamageBatcher.DamageType.NORMAL, "Bloody Syringe")

func get_flat_hp():
	return health
