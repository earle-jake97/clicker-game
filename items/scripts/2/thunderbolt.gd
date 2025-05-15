extends BaseItem

var tags = ["bounce", "thunderbolt"]
var rarity = 2
const item_name = "Thunderbolt"
const item_description = "Attacks will chain damage to an extra enemy."
const item_icon = preload("res://items/icons/thunderbolt.png")
var file_name = "res://items/scripts/2/thunderbolt.gd"

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	# Avoid infinite recursion: only one Thunderbolt handles the effect
	if source_item and "bounce" in source_item.tags:
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return


	# Count how many Thunderbolt items the player has
	var bounce_count = 3
	for item in player.inventory:
		if item.item_name == item_name:
			bounce_count += 1
		if "bounce_extend" in item.tags:
			bounce_count += item.get_bounces()  # optional

	var current_target = target
	var already_hit: Array[Node] = [target]

	for i in range(bounce_count):
		var nearest = null
		var shortest = INF

		for enemy in tree.get_nodes_in_group("enemy"):
			if enemy != current_target and enemy not in already_hit and enemy.is_inside_tree():
				var dist = current_target.global_position.distance_to(enemy.global_position)
				if dist < shortest:
					shortest = dist
					nearest = enemy

		if nearest:
			nearest.take_damage(round(player.calculate_damage().damage * 0.05))
			if player and player.has_method("proc_items"):
				player.proc_items(nearest, self)  # mark this Thunderbolt as the source
			already_hit.append(nearest)

			var bolt = preload("res://items/misc/LightningEffect.tscn").instantiate()
			bolt.setup(current_target.global_position, nearest.global_position)
			tree.current_scene.add_child(bolt)

			current_target = nearest
		else:
			break
