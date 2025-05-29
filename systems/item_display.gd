extends Control
@onready var number_label: Label = $number_label
@onready var texture_rect: TextureRect = $TextureRect
var entered = false
var item_data


func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	Tooltip.update_position(mouse_pos)


func setup(item_data, count: int = 1):
	self.item_data = item_data
	texture_rect.texture = item_data.item_icon
	if count <= 1:
		number_label.text = ""
	else:
		number_label.text = "x" + str(count)

func _on_texture_rect_mouse_entered() -> void:
	entered = true
	Tooltip.set_text(item_data.item_name + ": " + item_data.item_description)


func _on_texture_rect_mouse_exited() -> void:
	entered = false
	Tooltip.hide_tooltip()
