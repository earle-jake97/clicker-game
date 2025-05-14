extends Node

var oil_item_script := preload("res://items/scripts/2/oil.gd")
const OIL_EXPLOSION = preload("res://items/misc/oil_explosion.tscn")
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
		enemy_list.erase(enemy)
		spawn_oil_explosion(enemy.global_position, enemy)

func spawn_oil_explosion(position: Vector2, enemy: Node):
	var strength = 0
	for item in PlayerController.inventory:
		if item.item_name == "Oil":
			strength += 1

	var percent = oil_item_script.get_explosion_percentage(strength, 0.5)
	var damage = oil_item_script.get_explosion_damage(enemy.max_health, percent)
	var explosion = OIL_EXPLOSION.instantiate()
	explosion.global_position = position
	explosion.explosion_damage = damage
	explosion.z_index = explosion.global_position.y
	print("Spawning explosion at:", position, "with damage:", damage)
	add_child(explosion)
