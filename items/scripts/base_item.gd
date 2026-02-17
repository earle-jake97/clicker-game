extends Node2D
class_name BaseItem

var player = PlayerController

func _ready() -> void:
	print("buh")

func on_pickup(player):
	pass

func add_to_inventory():
	player.add_item(self)

func resolve_enemy_from_node(node):
	var current = node
	while current:
		if current.is_in_group("enemy"):
			return current
		current = current.get_parent()
	return null

func get_player_body():
	return player.get_player_body()
