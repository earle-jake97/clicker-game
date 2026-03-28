extends TextureProgressBar

@onready var modifier_icon_container: GridContainer = $ModifierRoot/ModifierIconContainer
@onready var status_effect_icon_container: GridContainer = $StatusEffectIconContainer

@export var icon_size: Vector2 = Vector2(50, 50)
@export var stack_label_offset: Vector2 = Vector2(2, 2)
@export var stack_label_horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_RIGHT
@export var stack_label_vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_BOTTOM

func set_modifier_icons(textures: Array[Texture2D]) -> void:
	_rebuild_modifier_icon_container(modifier_icon_container, textures)

func set_status_effect_icons(effect_data: Array) -> void:
	_rebuild_status_effect_icon_container(status_effect_icon_container, effect_data)

func _rebuild_modifier_icon_container(container: GridContainer, textures: Array[Texture2D]) -> void:
	if not is_instance_valid(container):
		return

	for child in container.get_children():
		child.queue_free()

	for texture in textures:
		if texture == null:
			continue

		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = icon_size
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(icon)

func _rebuild_status_effect_icon_container(container: GridContainer, effect_data: Array) -> void:
	if not is_instance_valid(container):
		return

	for child in container.get_children():
		child.queue_free()

	for entry in effect_data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		var texture: Texture2D = entry.get("texture", null)
		var stacks: int = entry.get("stacks", 1)

		if texture == null:
			continue

		var wrapper := Control.new()
		wrapper.custom_minimum_size = icon_size
		wrapper.size = icon_size

		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = icon_size
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wrapper.add_child(icon)

		if stacks > 1:
			var label := Label.new()
			label.text = str(stacks)

			label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			label.offset_right = 0
			label.offset_bottom = 0

			label.add_theme_font_size_override("font_size", 32)
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_constant_override("outline_size", 4)

			wrapper.add_child(label)

		container.add_child(wrapper)
