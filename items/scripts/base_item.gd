# res://items/effects/effect.gd
extends Node2D
class_name BaseItem

var player = PlayerController
var player_model = TestPlayer

func on_pickup(player):
	pass

func resolve_enemy_from_node(node):
	var current = node
	while current:
		if current.is_in_group("enemy"):
			return current
		current = current.get_parent()
	return null
