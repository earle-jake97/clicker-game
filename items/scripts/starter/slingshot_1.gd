extends BaseItem

const item_name = "Splitshot"
const item_description = "Every attack shoots a second shot that targets the most dangerous enemy. 
These shots do 5 damage, will not trigger on procs and do not proc other items."
var tags = []
var item_icon = preload("res://items/icons/starter_items/splitshot.png")
const file_name = "res://items/scripts/starter/slingshot_1.gd"
var damage = 5

func on_attack(target: Node, source_item: BaseItem = null):
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
	var enemies = player.get_enemies_in_range(get_player_body().global_position)
	
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

func spawn_slingshot_projectile(target, result, size: float = 1.0, damage_source: String = "Player Attack", can_proc: bool = true):
	var projectile_scene = preload("res://characters/goblin/slingshot_projectile.tscn")
	var projectile = projectile_scene.instantiate()
	projectile.global_position = player.get_player_body().get_sling_position()
	var target_position = target.global_position 
	if target.find_child("pivot", 1, 1):
		target_position = target.find_child("pivot", 1, 1).global_position
	target_position += Vector2(randf_range(-30, 30), randf_range(-30, 30))
	projectile.target_position = target_position
	projectile.scale *= size
	projectile.damage = result
	projectile.on_reach = Callable(self, "_deal_damage_to_enemy").bind(target, result, damage_source, can_proc)
	get_tree().current_scene.add_child(projectile)
