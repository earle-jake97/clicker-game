extends BaseItem

const item_name = "Explosive Shot"
const item_description = "Every attack detonates, dealing 2 damage in a small area around your target."
var tags = []
var item_icon = preload("res://items/icons/starter_items/explosive_shot.png")
const file_name = "res://items/scripts/starter/slingshot_2.gd"
var damage = 2
var radius = 105

func starter_proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		print("?")
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	
	if not tree:
		return

	var target_position = get_target_position(target)
	var enemies = get_enemies_in_radius(target_position)
	
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage, DamageBatcher.DamageType.NORMAL, "Explosive Shot")

func get_target_position(target):
	var target_position = Vector2.ZERO
	if target.find_child("pivot", 1, 1):
		target_position = target.find_child("pivot", 1, 1).global_position
	else:
		target_position = target.global_position
	return target_position

func get_enemies_in_radius(center_position):
	var space = get_player_body().get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	
	query.shape = shape
	query.transform = Transform2D(0, center_position)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space.intersect_shape(query, 64)
	var enemies = []
	for hit in results:
		var area = hit.collider
		var enemy = resolve_enemy_from_node(area)
		if enemy:
			enemies.append(enemy)
	
	return enemies
