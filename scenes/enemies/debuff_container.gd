extends HBoxContainer

var debuff_icons := {
	debuff.Debuff.BLEED: preload("res://items/misc/bleed_icon.png"),
	debuff.Debuff.OIL: preload("res://items/misc/oil_icon.png"),
	debuff.Debuff.CHILL: preload("res://items/misc/ice_icon.png"),
}
@onready var debuff_container: HBoxContainer = $"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_debuffs():
	for child in get_children():
		child.queue_free()
	for debuff in get_parent().debuffs:
		if debuff_icons.has(debuff):
			var icon = TextureRect.new()
			icon.texture = debuff_icons[debuff]
			icon.stretch_mode = TextureRect.STRETCH_KEEP
			icon.custom_minimum_size = Vector2(12, 12)  # Optional, forces size in layout
			debuff_container.add_child(icon)
