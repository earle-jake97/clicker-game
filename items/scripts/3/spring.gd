extends BaseItem
const item_name = "Spring"
const item_description = "Any item that bounces between enemies bounces two extra times."
const item_icon = preload("res://items/icons/spring.png")
const tags = ["bounce_extend"]
const rarity = 3
var file_name = "res://items/scripts/3/spring.gd"
var occurrences = 2


func _process(delta: float) -> void:
	pass
