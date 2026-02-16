extends BaseItem
const item_name = "Bowling Ball"
const item_description = "5% chance to roll a bowling ball at the nearest enemy on hit."
const item_icon = preload("res://items/icons/bowling_ball.png")
const tags = []
const rarity = 2
var file_name = "res://items/scripts/2/bowling_ball.gd"
var chance = 0.05

@export var ball_scene = preload("res://items/misc/bowling_ball_projectile.tscn")

func proc(target: Node, source_item: BaseItem = null):
	var location = target.global_position
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	# Determine damage
	var ran = PlayerController.calculate_luck()
	if ran > chance:
		return
	var strength = 0
	for item in player.inventory:
		if "Bowling Ball" in item.item_name:
			strength += 1
	strength * 0.75
	instantiate_ball(target, tree, strength)


func instantiate_ball(target: Node, tree, multiplier):
	var proj = ball_scene.instantiate()
	var result = player.calculate_damage()
	proj.damage = result.damage * multiplier
	proj.speed = randf_range(1000.0, 1200.0)
	proj.start_pos = get_player_body().global_position - Vector2(0, 10)
	proj.target_pos = target.global_position
	proj.crit = result.crit
	tree.current_scene.add_child(proj)
