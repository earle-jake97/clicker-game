extends BaseItem
const item_name = "Number Fanatic"
const item_description = "Toss a projectile that bounces to enemies, with ramping up damage each bounce."
const item_icon = preload("res://items/icons/number_fanatic.png")
const tags = ["timer", "bounce"]
const rarity = 2
var file_name = "res://items/scripts/2/number_fanatic.gd"
var occurrences = 1
var player_body = TestPlayer

@export var bounce_projectile_scene = preload("res://items/misc/nubby_projectile.tscn")
var cooldown_timer := 0.0
var cooldown := 2.5 # Time between automatic chain lightning casts
var delay_between_throws = 0

func _ready() -> void:
	connect("reset", Callable(self, "queue_free"))

func _process(delta):
	if not player:
		return
	
	delay_between_throws += delta
	
	cooldown_timer += delta
	if cooldown_timer >= cooldown:
		cooldown_timer = 0.0
		fire_chain_lightning()


func fire_chain_lightning():
	var first_target = get_nearest_enemy(player_body.global_position, null)
	if first_target:
		launch_bounce_projectile(first_target, 0, [])
		for item in PlayerController.inventory:
			if "timer_procs" in item.tags:
				for i in range(item.occurrences):
					launch_bounce_projectile(first_target, 0, [])
		
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

func launch_bounce_projectile(target: Node, bounce_index: int, hit_chain: Array):
	var proj = bounce_projectile_scene.instantiate()
	var result = player.calculate_damage()
	proj.global_position = Vector2(-10000, -10000)
	proj.start_pos = player_body.global_position
	proj.target = target
	proj.bounce_index = bounce_index
	proj.hit_chain = hit_chain.duplicate()
	proj.damage = result.damage * pow(1.25, bounce_index)
	proj.crit = result.crit
	proj.player = player
	get_tree().current_scene.add_child(proj)
