extends Node2D

@onready var hands: Sprite2D = $Hands

@onready var item_tree = get_tree().get_nodes_in_group("item")
@onready var heart_tree = get_tree().get_nodes_in_group("heart")
@onready var exit: Button = $Exit


var hover_exit = false
const BROKE = preload("res://systems/shop/player_hands2.png")
const WOKE = preload("res://systems/shop/player_hands.png")
const SHOPKEEP = preload("res://systems/shop/shopkeep.png")
const SHOPKEEP_MAD = preload("res://systems/shop/shopkeep_mad.png")
const BOSS_1_MAP = preload("res://systems/map/boss_scenes/boss_1_map.tscn")
var difficulty_scaling = 0.15
var lowest_price = 30
var used_item_paths: Array[String] = []

const MAX_ATTEMPTS := 30


func _ready() -> void:
	PlayerController.difficulty -= 1 # Bandaid fix
	HealthBar.button.visible = false
	HealthBar.fast_forward = false
	set_up_items()

func set_up_items():
	var ok = ItemSpawner.populate_shop(
		item_tree,
		PlayerController.difficulty,
		func(price):
			if price < lowest_price:
				lowest_price = price
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
	match rarity:
		4:
			return round(50 + PlayerController.difficulty * 2)
		3:
			return round(35 + PlayerController.difficulty * 1.8)
		2:
			return round(20 + PlayerController.difficulty * 1.5)
		_:
			return round(10 + PlayerController.difficulty * 1.1)

func get_health_price(rarity: int) -> int:
	match rarity:
		4:
			return round(50 + PlayerController.difficulty * 2)
		3:
			return round(35 + PlayerController.difficulty * 1.8)
		2:
			return round(20 + PlayerController.difficulty * 1.5)
		_:
			
			return round(10 + PlayerController.difficulty * 1.1)

# Helper function to apply discount
func apply_discount(base_price: int) -> int:
	var rand = randf()
	if rand <= 0.05:  # 5% chance for 50% discount
		return int(base_price * 0.5)
	elif rand <= 0.10:  # 10% chance for 15% discount (total 15% for 5% + 10%)
		return int(base_price * 0.85)
	else:
		return base_price  # No discount

func _get_unique_item_script(get_script_func: Callable, used_paths: Array[String]):
	for i in range(MAX_ATTEMPTS):
		var script = get_script_func.call()
		if not script:
			return null

		if script.resource_path not in used_paths:
			used_paths.append(script.resource_path)
			return script

	# Could not find a unique item
	return null


func _on_exit_pressed() -> void:
	var items_unpurchased = get_tree().get_nodes_in_group("item")
	print("Items unpurchased", items_unpurchased)
	ItemSpawner.return_unused_items(items_unpurchased)
	SceneManager.switch_to_scene("res://map/map_scene.tscn")
