extends BaseItem

const item_name = "Splitshot"
const item_description = "Every attack shoots a second shot that targets the most dangerous enemy. 
These shots do 5 damage, will not trigger on procs and do not proc other items."
var tags = []
var item_icon = preload("res://sprites/aaron.png")
const file_name = "res://items/scripts/starter/slingshot_1.gd"
var damage = 5

func starter_proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	
	if not tree:
		return
	var result = {
		"damage": damage,
		"crit": false
	}
	
	target = seek_strongest_enemy()
	if target != null:
		player.spawn_slingshot_projectile(target, result, 0.5, "Splitshot", false)


func seek_strongest_enemy():
	var max_hp = 0
	var strongest_enemy: Node2D = null
	var enemies = player.get_enemies_in_range(player_model.global_position)
	
	if enemies.is_empty():
		return
		
	for enemy in enemies:
		if not enemy.has_method("take_damage"):
			continue

		if enemy.max_health > max_hp:
			max_hp = enemy.max_health
			strongest_enemy = enemy

	if strongest_enemy == null:
		return

	return strongest_enemy
