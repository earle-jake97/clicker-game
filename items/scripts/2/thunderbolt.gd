extends BaseItem

var tags = ["bounce", "thunderbolt"]
var rarity = 2
const item_name = "Thunderbolt"
const item_description = "Attacks will chain damage to an extra enemy. These attacks also have a 20% chance to proc other item effects."
const item_icon = preload("res://items/icons/thunderbolt.png")
var file_name = "res://items/scripts/2/thunderbolt.gd"
var bounce_radius_x = 600
var bounce_radius_y = 420

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
		if "bounce_extend" in item.tags:
			bounce_count += item.get_bounces()  # optional

	var current_target = target

	for i in range(bounce_count):
		var nearest = null
		var shortest = INF
		var procs = false

		for enemy in tree.get_nodes_in_group("enemy"):
			if enemy != current_target and enemy.is_inside_tree():
				var dist = current_target.global_position.distance_to(enemy.global_position)
				var dx = (enemy.global_position.x - current_target.global_position.x) / bounce_radius_x
				var dy = (enemy.global_position.y - current_target.global_position.y) / bounce_radius_y
				if (dx * dx + dy * dy) <= 1.0:
					if dist < shortest:
						shortest = dist
						nearest = enemy

		if nearest:
			nearest.take_damage(round(player.calculate_damage().damage * 0.05), DamageBatcher.DamageType.NORMAL, "Thunderbolt")
			if player and player.has_method("proc_items"):
				var rand = PlayerController.calculate_luck()
				if rand <= 0.2:
					procs = true
					player.proc_items(nearest, self)  # mark this Thunderbolt as the source

			var bolt = preload("res://items/misc/LightningEffect.tscn").instantiate()
			bolt.top_level = true
			var target_pivot_1
			var target_pivot_2
			if current_target.find_child("pivot", 1, 1):
				target_pivot_1 = current_target.find_child("pivot", 1, 1).global_position
			else:
				target_pivot_1 = current_target.global_position
			if nearest.find_child("pivot", 1, 1):
				target_pivot_2 = nearest.find_child("pivot", 1, 1).global_position
			else:
				target_pivot_2 = nearest.global_position
			bolt.setup(target_pivot_1, target_pivot_2, procs)
			tree.current_scene.add_child(bolt)

			current_target = nearest
		else:
			break
