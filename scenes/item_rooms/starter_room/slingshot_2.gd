extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@export var item_name = "test_name"
@export var item_description = "does bladfljsdlafasfgbask klbdsf lkjsbdflk sadk bsadffk bjkbs kbsafd kbfasd ksdfk jasfdk afsdkbasd fk"
const MAP_VIEW = preload("res://map/map_scene.tscn")
var item_file_name 
var item_path 
var entered = false
var item = preload("res://items/scripts/starter/slingshot_2.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_name = item.item_name
	item_description = item.item_description
	item_file_name = item.file_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if entered:
		if Input.is_action_just_pressed("Click"):
			var item_script = item.new()
			PlayerController.add_item(item_script)
			Tooltip.hide_tooltip()
			SceneManager.switch_to_scene("res://map/map_scene.tscn")

func _on_area_2d_mouse_entered() -> void:
	entered = true
	Tooltip.set_text(item_name, item_description)

func _on_area_2d_mouse_exited() -> void:
	entered = false
	Tooltip.hide_tooltip()
