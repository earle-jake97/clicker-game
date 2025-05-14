extends Control
@onready var label: Label = $PanelContainer/Label


func _ready():
	set_as_top_level(true)


func set_text(text: String) -> void:
	if label:
		label.text = text
		await get_tree().process_frame  # Ensures layout updates
		custom_minimum_size = $PanelContainer.size  # Force size to match content
		show()


func update_position(mouse_pos: Vector2) -> void:
	var offset = Vector2(20, 20)
	await get_tree().process_frame  # Wait a frame to ensure size is updated
	var screen_size = get_viewport().get_visible_rect().size
	var tooltip_size = get_rect().size
	global_position = (mouse_pos + offset).clamp(Vector2.ZERO, screen_size - tooltip_size)


func hide_tooltip() -> void:
	hide()
