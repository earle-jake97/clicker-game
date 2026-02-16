extends Control

@onready var sprite_2d: Button = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var deferral: Button = $deferral

var room_category
var room_name
var room_name_string
var room_sprite
var room_description
var hide_deferral = false

signal selected(room_name: int)
signal deferred(room_name: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.icon = room_sprite
	if not MapManager.can_defer():
		deferral.hide()
	if hide_deferral:
		deferral.hide()
	
func _on_sprite_2d_pressed() -> void:
	emit_signal("selected", room_name)
	Tooltip.hide_tooltip()

func _on_sprite_2d_mouse_entered() -> void:
	Tooltip.set_text(RoomDatabase.get_room_name(room_name), room_description)

func _on_sprite_2d_mouse_exited() -> void:
	Tooltip.hide_tooltip()

func _on_deferral_mouse_entered() -> void:
	Tooltip.set_text("Defer", "Defer this room. If you do this, you can skip it for now, but you will be forced to enter it before the boss.")

func _on_deferral_mouse_exited() -> void:
	Tooltip.hide_tooltip()

func _on_deferral_pressed() -> void:
	emit_signal("deferred", room_name)
