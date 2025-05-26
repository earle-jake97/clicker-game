extends Node2D

@onready var hands: Sprite2D = $Hands
@onready var area_2d: Area2D = $Area2D

@onready var item_tree = get_tree().get_nodes_in_group("item")
@onready var heart_tree = get_tree().get_nodes_in_group("heart")
@export var shop_id: int

var hover_exit = false
const BROKE = preload("res://systems/shop/player_hands2.png")
const WOKE = preload("res://systems/shop/player_hands.png")
const MapView = preload("res://map/map_view.tscn")

var difficulty_scaling = 0.15
var lowest_price = 30

func _ready() -> void:
	TestPlayer.visible = false
	HealthBar.button.visible = false
	HealthBar.fast_forward = false
	set_up_items()

func _process(delta: float) -> void:
	if hover_exit and Input.is_action_just_pressed("Click"):
		Tooltip.hide_tooltip()
		if GameState.endless_mode:
			SceneManager.switch_to_scene("res://systems/map/horde_scenes/horde_endless.tscn")
		SceneManager.switch_to_scene("res://map/map_view.tscn")
		GameState.on_map_screen = true

	hands.texture = WOKE if PlayerController.cash > lowest_price else BROKE

func set_up_items():
	for item in item_tree:
		var rarity = roll_rarity()
		var base_price = get_price_for_rarity(rarity)

		var script = ItemDatabase.get_random_item_by_rarity(rarity)
		if script:
			var instance = script.new()
			var price = apply_discount(base_price)
			if price < lowest_price:
				lowest_price = price
			var discounted = false
			if price != base_price:
				discounted = true

			item.assign_item(
				instance.item_icon,
				instance.item_name,
				instance.item_description,
				script.resource_path,
				price,
				discounted,
				rarity
			)

func roll_rarity():
	var rand = randf()
	if rand <= 0.35:
		return 4
	elif rand <= 0.35:
		return 3
	elif rand <= 0.20:
		return 2
	else:
		return 1

func get_price_for_rarity(rarity: int) -> int:
	var difficulty = PlayerController.difficulty
	match rarity:
		4:
			return 120 * ((difficulty*difficulty_scaling) + 1)
		3:
			return 75 * ((difficulty*difficulty_scaling) + 1)
		2:
			return 55 * ((difficulty*difficulty_scaling) + 1)
		_:
			
			return 40 * ((difficulty*difficulty_scaling) + 1)

# Helper function to apply discount
func apply_discount(base_price: int) -> int:
	var rand = randf()
	if rand <= 0.1:  # 10% chance for 50% discount
		return int(base_price * 0.5)
	elif rand <= 0.15:  # 15% chance for 15% discount (total 15% for 5% + 10%)
		return int(base_price * 0.85)
	else:
		return base_price  # No discount

func _on_area_2d_mouse_entered() -> void:
	hover_exit = true


func _on_area_2d_mouse_exited() -> void:
	hover_exit = false
