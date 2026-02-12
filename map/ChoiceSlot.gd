extends Control

@onready var sprite_2d: Button = $Sprite2D

var room_category
var room_name
var room_sprite

signal selected(room_name: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.icon = room_sprite
	pass

func _on_sprite_2d_pressed() -> void:
	emit_signal("selected", room_name)
