extends Node2D

@onready var hands: Sprite2D = $Hands
@onready var area_2d: Area2D = $Area2D

@onready var item_tree = get_tree().get_nodes_in_group("item")
@onready var heart_tree = get_tree().get_nodes_in_group("heart")


var hover_exit = false
const BROKE = preload("res://systems/shop/player_hands2.png")
const WOKE = preload("res://systems/shop/player_hands.png")
const SHOPKEEP = preload("res://systems/shop/shopkeep.png")
const SHOPKEEP_MAD = preload("res://systems/shop/shopkeep_mad.png")
var difficulty_scaling = 0.15
var lowest_price = 30

func _ready() -> void:
	set_up_items()

func _process(delta: float) -> void:
	if hover_exit and Input.is_action_just_pressed("Click"):
		GameState.leave_shop_triggered = true

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
			print("Difficulty:", PlayerController.difficulty)
			print("Rarity:", rarity)
			print("Base price:", base_price)
			print("Final price:", price)

			item.assign_item(
				instance.item_icon,
				instance.item_name,
				instance.item_description,
				script.resource_path,
				price,
				discounted,
				rarity
			)
	for heart in heart_tree:
		var rarity = roll_heart_rarity()
		var base_price = get_health_price(rarity)

		var script = ItemDatabase.get_random_heart_by_rarity(rarity)
		if script:
			var instance = script.new()
			var price = apply_discount(base_price)
			if price < lowest_price:
				lowest_price = price
			var discounted = false
			if price != base_price:
				discounted = true

			heart.assign_item(
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
	if rand <= 0.05:
		return 4
	elif rand <= 0.15:
		return 3
	elif rand <= 0.4:
		return 2
	else:
		return 1

func roll_heart_rarity():
	var rand = randf()
	if rand <= 0.15:
		return 4
	elif rand <= 0.35:
		return 3
	elif rand <= 0.60:
		return 2
	else:
		return 1

func get_price_for_rarity(rarity: int) -> int:
	var difficulty = PlayerController.difficulty
	match rarity:
		4:
			return 100 * ((difficulty*difficulty_scaling) + 1)
		3:
			return 70 * ((difficulty*difficulty_scaling) + 1)
		2:
			return 45 * ((difficulty*difficulty_scaling) + 1)
		_:
			
			return 30 * ((difficulty*difficulty_scaling) + 1)

func get_health_price(rarity: int) -> int:
	var difficulty = PlayerController.difficulty
	match rarity:
		4:
			return 50 * ((difficulty*difficulty_scaling) + 1)
		3:
			return 35 * ((difficulty*difficulty_scaling) + 1)
		2:
			return 20 * ((difficulty*difficulty_scaling) + 1)
		_:
			
			return 10 * ((difficulty*difficulty_scaling) + 1)

# Helper function to apply discount
func apply_discount(base_price: int) -> int:
	var rand = randf()
	if rand <= 0.05:  # 5% chance for 50% discount
		return int(base_price * 0.5)
	elif rand <= 0.10:  # 10% chance for 15% discount (total 15% for 5% + 10%)
		return int(base_price * 0.85)
	else:
		return base_price  # No discount



func _on_area_2d_mouse_entered() -> void:
	hover_exit = true


func _on_area_2d_mouse_exited() -> void:
		hover_exit = false
