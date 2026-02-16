extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@export var item_name = "test_name"
@export var item_description = "does bladfljsdlafasfgbask klbdsf lkjsbdflk sadk bsadffk bjkbs kbsafd kbfasd ksdfk jasfdk afsdkbasd fk"
const MAP_VIEW = preload("res://map/map_scene.tscn")
var item_file_name 
var item_path 
var entered = false
var item
var anger_timer = 0
var anger_timer_active = false

signal leave_room

@onready var price: Label = $price
@onready var quality_sprite: Sprite2D = $Quality
const QUALITY_1 = preload("res://items/misc/quality_1.png")
const QUALITY_2 = preload("res://items/misc/quality_2.png")
const QUALITY_3 = preload("res://items/misc/quality_3.png")
const QUALITY_4 = preload("res://items/misc/quality_4.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if entered:
		if Input.is_action_just_pressed("Click"):
				item_path = item_file_name
				item = load(item_path)
				if item == null:
					return
				var item_script = item.new()
				PlayerController.add_item(item_script)
				Tooltip.hide_tooltip()
				GameState.on_map_screen = true
				GameState.leave_shop_triggered = true
				leave_room.emit()

# Assign item properties for the item
func assign_item(item_icon, item_name, item_description, item_file_name, price, rarity):
	sprite_2d.texture = item_icon
	self.item_name = item_name
	self.item_description = item_description
	self.item_file_name = item_file_name
	if rarity == 1:
		self.quality_sprite.texture = QUALITY_1
	elif rarity == 2:
		self.quality_sprite.texture = QUALITY_2
	elif rarity == 3:
		self.quality_sprite.texture = QUALITY_3
	else:
		self.quality_sprite.texture = QUALITY_4


func _on_area_2d_mouse_entered() -> void:
	entered = true
	Tooltip.set_text(item_name, item_description)
	quality_sprite.visible = true

func _on_area_2d_mouse_exited() -> void:
	entered = false
	Tooltip.hide_tooltip()
	quality_sprite.visible = false
