extends Node2D

@onready var item_tree = get_tree().get_nodes_in_group("item")
const MAP = "res://map/map_scene.tscn"
func _ready() -> void:
	HealthBar.button.visible = false
	HealthBar.fast_forward = false
