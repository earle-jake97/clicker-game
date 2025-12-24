extends Node

var burrito_script := preload("res://items/scripts/4/michaels_burrito.gd")
var oil_item_script := preload("res://items/scripts/2/oil.gd")
const OIL_EXPLOSION = preload("res://items/misc/oil_explosion.tscn")
const BURRITO_PUDDLE = preload("res://items/misc/burrito_puddle.tscn")
const SCRIMBLO = preload("res://items/scrimblo/scrimblo.tscn")
var enemy_list = []
func _ready():
	# Optionally, watch for enemies added dynamically
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _on_node_added(node):
	if node.is_in_group("enemy") and "died" in node:
		enemy_list.append(node)
		node.died.connect(_on_enemy_died.bind(node))
func _on_enemy_died(enemy):
	if enemy not in enemy_list:
		return
	enemy_list.erase(enemy)
	if GameState.horde_bool:
		GameState.enemy_count -= 1
	if enemy.debuffs.has(debuff.Debuff.OIL):
		if PlayerController.calculate_luck() <= oil_item_script.explosion_chance:
			spawn_oil_explosion(enemy.global_position, enemy)
	var chance = burrito_script.calculate_puddle_chance()
	if chance.puddle_chance >= chance.random_value:
		spawn_blood_puddle(enemy.global_position)
	PlayerController.grant_shields(GameState.scythe_amount * 5)
	var scrimblo_random = PlayerController.calculate_luck()
	if scrimblo_random <= 0.08:
		spawn_scrimblo(TestPlayer.global_position + Vector2(randf_range(120, 400), randf_range(-60, 60)))
		
	
	
func spawn_scrimblo(position: Vector2):
	var health = 0
	for item in PlayerController.inventory:
		if item.item_name == "Scrimblo":
			health += 80
	if health == 0:
		return
	var scrimblo = SCRIMBLO.instantiate()
	scrimblo.global_position = position
	scrimblo.max_hp = health
	add_child(scrimblo)

func spawn_blood_puddle(position: Vector2):
	var strength = 0
	for item in PlayerController.inventory:
		if item.item_name == "Michael's Burrito":
			strength += 1
	if strength == 0:
		return
	var puddle = BURRITO_PUDDLE.instantiate()
	puddle.puddle_damage = (burrito_script.percent_dmg + (0.1 * strength)) * PlayerController.calculate_damage().damage
	puddle.global_position = position
	add_child(puddle)

func spawn_oil_explosion(position: Vector2, enemy: Node):
	var strength = 1
	for item in PlayerController.inventory:
		if item.item_name == "Oil":
			strength += 1

	var percent = oil_item_script.get_explosion_percentage(strength, 0.5)
	var damage = oil_item_script.get_explosion_damage(enemy.max_health, percent)
	var explosion = OIL_EXPLOSION.instantiate()
	explosion.global_position = position
	explosion.explosion_damage = damage
	explosion.z_index = explosion.global_position.y
	add_child(explosion)
