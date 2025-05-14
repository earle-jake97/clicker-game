extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@export var item_name = "test_name"
@export var item_description = "does bladfljsdlafasfgbask klbdsf lkjsbdflk sadk bsadffk bjkbs kbsafd kbfasd ksdfk jasfdk afsdkbasd fk"
@onready var quality_sprite: Sprite2D = $Quality_sprite


var item_file_name
var cost
var item_path
var entered = false
var item
var anger_timer = 0
var anger_timer_active = false
var rarity
@onready var price: Label = $price
var discounted = false
const QUALITY_1 = preload("res://items/misc/quality_1.png")
const QUALITY_2 = preload("res://items/misc/quality_2.png")
const QUALITY_3 = preload("res://items/misc/quality_3.png")
const QUALITY_4 = preload("res://items/misc/quality_4.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if anger_timer_active:
		anger_timer += delta
		if anger_timer >= 0.1:
			_on_timer_finished()
			anger_timer_active = false

	if entered:
		var mouse_pos = get_viewport().get_mouse_position()
		Tooltip.update_position(mouse_pos)

		if Input.is_action_just_pressed("Click"):
			item_path = item_file_name
			if PlayerController.cash >= cost:
				item = load(item_path)
				if item == null:
					return
				var item_script = item.new()
				PlayerController.add_item(item_script)
				PlayerController.cash -= cost
				print("Player Items: " + str(PlayerController.inventory))
				Tooltip.hide_tooltip()
				queue_free()
			else:
				madWizard()


# Assign item properties for the item
func assign_item(item_icon, item_name, item_description, item_file_name, price, discounted, rarity):
	sprite_2d.texture = item_icon
	self.item_name = item_name
	self.item_description = item_description
	self.item_file_name = item_file_name
	self.cost = price
	self.price.text = str(price)
	if rarity == 1:
		self.quality_sprite.texture = QUALITY_1
	elif rarity == 2:
		self.quality_sprite.texture = QUALITY_2
	elif rarity == 3:
		self.quality_sprite.texture = QUALITY_3
	else:
		self.quality_sprite.texture = QUALITY_4
		
	# Check if the price is discounted, if so change the price label color
	if discounted:  # If the price is discounted
		self.price.add_theme_color_override("font_color", Color(1, 0, 0))  # Red color
	else:
		self.price.add_theme_color_override("font_color", Color.WEB_GREEN)  # Reset to default white

func _on_area_2d_mouse_entered() -> void:
	entered = true
	Tooltip.set_text(item_name + ": " + item_description)
	quality_sprite.visible = true

func _on_area_2d_mouse_exited() -> void:
	entered = false
	Tooltip.hide_tooltip()
	quality_sprite.visible = false


func madWizard():
	GameState.shopkeeper_mad = true
	anger_timer = 0.0
	anger_timer_active = true

func _on_timer_finished():
	GameState.shopkeeper_mad = false
