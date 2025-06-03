extends BaseItem

var elapsed_time := 0.0
const TIMER_DURATION := 2
var amount_of_times_to_click = 1
const item_name = "Missing Soul"
const item_description = "Every 2 seconds, a soul bombards a random enemy, dealing 3 times your damage in an area."
var tags = ["timer", "area"]
var rarity = 3
var item_icon = preload("res://items/icons/missing_soul.png")
var file_name = "res://items/scripts/3/missing_soul.gd"
var timer_procs = 0
var projectile_scene = preload("res://items/misc/ghost_projectile.tscn")

func _ready() -> void:
	connect("reset", Callable(self, "queue_free"))

func check_timers():
	timer_procs = 0
	for item in player.inventory:
		var tags = item.tags
		if "timer_procs" in tags:
			timer_procs += item.occurrences
	return timer_procs

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= TIMER_DURATION:
		elapsed_time -= TIMER_DURATION 
		for i in range(check_timers() + 1):
			spawn_ghost()

func spawn_ghost():
	var tree = player.get_tree()
	if not tree:
		return

	var enemies = tree.get_nodes_in_group("enemy")
	if enemies.is_empty():
		return

	var target_enemy = enemies[randi() % enemies.size()]
	if not is_instance_valid(target_enemy):
		return

	var projectile = projectile_scene.instantiate()
	var randy = randi_range(-200, 15)
	var randx = randi_range(-20, 20)
	projectile.global_position = Vector2((target_enemy.global_position.x - 30) + randx, -20 + randy)  # Off-screen above
	projectile.target_position = target_enemy.global_position
	projectile.player = player  # So it knows who to use for damage
	projectile.damage_multiplier = 3.0
	tree.current_scene.add_child(projectile)
