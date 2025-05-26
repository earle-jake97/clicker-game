extends Node

var burrito_script := preload("res://items/scripts/4/michaels_burrito.gd")
var oil_item_script := preload("res://items/scripts/2/oil.gd")
const OIL_EXPLOSION = preload("res://items/misc/oil_explosion.tscn")
const BURRITO_PUDDLE = preload("res://items/misc/burrito_puddle.tscn")
var enemy_list = []
func _ready():
	# Optionally, watch for enemies added dynamically
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _on_node_added(node):
	if node.is_in_group("enemy") and "died" in node:
		enemy_list.append(node)
		node.died.connect(_on_enemy_died.bind(node))

func _on_enemy_died(enemy):
	if enemy.has_meta("oil_applied") and enemy in enemy_list:
		spawn_oil_explosion(enemy.global_position, enemy)
	if enemy.has_meta("burrito") and enemy in enemy_list:
		var chance = burrito_script.calculate_puddle_chance()
		if chance.puddle_chance >= chance.random_value:
			spawn_blood_puddle(enemy.global_position)
	enemy_list.erase(enemy)
	

func spawn_blood_puddle(position: Vector2):
	var strength = 0
	for item in PlayerController.inventory:
		if item.item_name == "Michael's Burrito":
			strength += 1
	
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
