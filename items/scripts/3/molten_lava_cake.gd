extends BaseItem
const item_name = "Molten Lava Cake"
const item_description = "5% chance to launch 5 fireballs upon hitting an enemy. These fireballs do twice your damage and can crit."
const item_icon = preload("res://items/icons/molten_lava_cake.png")
const tags = ["fire"]
const rarity = 3
var file_name = "res://items/scripts/3/molten_lava_cake.gd"
@export var meatball_scene = preload("res://items/misc/meatball.tscn")


func proc(target: Node, source_item: BaseItem = null):
	var location = target.global_position
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	# Determine damage
	var ran = PlayerController.calculate_luck()
	if ran > 0.05:
		return
	var strength = 0
	for item in player.inventory:
		if "Molten Lava Cake" in item.item_name:
			strength += 1
	spawn_fireballs(location, tree)

func spawn_fireballs(target, tree):
	for i in range(5):
		var fireball = meatball_scene.instantiate()
		fireball.start_pos = target
		fireball.damage = player.calculate_damage(DamageBatcher.DamageType.NORMAL, 2.0).damage
		tree.current_scene.add_child(fireball)
