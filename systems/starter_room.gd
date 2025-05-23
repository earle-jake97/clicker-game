extends Node2D

@onready var item_tree = get_tree().get_nodes_in_group("item")
const MAP = "res://map/map_view.tscn"
func _ready() -> void:
	set_up_items()
	connect_signal()

func set_up_items():
	for item in item_tree:
		var rarity = 2
		var starter_item = ItemDatabase.get_starter_items()
		if starter_item:
			var instance = starter_item
			item.assign_item(instance.item_icon, instance.item_name, instance.item_description, instance.file_name, 0, rarity)

func connect_signal():
	for item in item_tree:
		item.leave_room.connect(_exit_room)

func _exit_room():
	SceneManager.switch_to_scene(MAP)
	
