extends Node2D
@onready var text_edit: TextEdit = $TextEdit
@onready var leave_button: Button = $leave_button
@onready var testmap: Button = $testmap
@onready var itemdb: Button = $itemdb


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	var input = text_edit.text
	for item_script in ItemDatabase.items:
		var instance = item_script.new()
		if instance.item_name == input:
			PlayerController.add_item(instance)
			print("Added ", instance.item_name, " to inventory.")

func _on_leave_button_pressed() -> void:
	SceneManager.switch_to_scene("res://map/map_scene.tscn")


func _on_testmap_pressed() -> void:
	SceneManager.switch_to_scene("res://scenes/test_map.tscn")


func _on_itemdb_pressed() -> void:
	for item in ItemDatabase.items:
		print(item.resource_path)
