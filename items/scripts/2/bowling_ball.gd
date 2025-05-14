extends BaseItem
const item_name = "Bowling Ball"
const item_description = "Roll a bowling ball in a straight line towards the nearest enemy every two seconds."
const item_icon = preload("res://items/icons/bowling_ball.png")
const tags = ["timer"]
const rarity = 2
var file_name = "res://items/scripts/2/bowling_ball.gd"
var occurrences = 1
var player_body = TestPlayer

@export var ball_scene = preload("res://items/misc/bowling_ball_projectile.tscn")
var cooldown_timer := 0.0
var cooldown := 2.0 
var delay_between_throws = 0

func _process(delta):
	if not player:
		return
	
	delay_between_throws += delta
	
	cooldown_timer += delta
	if cooldown_timer >= cooldown:
		cooldown_timer = 0.0
		throw_ball()


func throw_ball():
	var first_target = get_nearest_enemy(player_body.global_position, null)
	if first_target:
		instantiate_ball(first_target)
		for item in PlayerController.inventory:
			if "timer_procs" in item.tags:
				for i in range(item.occurrences):
					instantiate_ball(first_target)
		
func get_nearest_enemy(from_pos: Vector2, exclude: Node) -> Node:
	var nearest = null
	var shortest = INF
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy != exclude and enemy.is_inside_tree():
			var dist = from_pos.distance_to(enemy.global_position)
			if dist < shortest:
				shortest = dist
				nearest = enemy
	return nearest

func instantiate_ball(target: Node):
	var proj = ball_scene.instantiate()
	var result = player.calculate_damage()
	proj.damage = result.damage
	proj.speed = randf_range(1000.0, 1200.0)
	proj.start_pos = player_body.global_position - Vector2(0, 10)
	proj.target_pos = target.global_position
	proj.crit = result.crit
	get_tree().current_scene.add_child(proj)
