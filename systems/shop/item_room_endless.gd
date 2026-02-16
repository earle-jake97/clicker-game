extends Node2D

@onready var item_tree = get_tree().get_nodes_in_group("item")

func _ready() -> void:
	HealthBar.button.visible = false
	HealthBar.fast_forward = false
	set_up_items()

func set_up_items():
	for item in item_tree:
		var rarity = roll_rarity()
		var script = ItemDatabase.get_random_item_by_rarity(rarity)
		if script:
			var instance = script.new()
			item.assign_item(instance.item_icon, instance.item_name, instance.item_description, script.resource_path, 0, rarity)

func roll_rarity():
	var rand = randf()
	if rand <= 0.05:
		return 4
	elif rand <= 0.2:
		return 3
	elif rand <= 0.5:
		return 2
	else:
		return 1
