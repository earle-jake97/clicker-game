extends Node
class_name ShopItemSpawner

const MAX_ATTEMPTS := 25

func populate_items(
	items: Array,
) -> bool:
	var used_item_paths: Array[String] = []
	var used_heart_paths: Array[String] = []

	# Items
	for item in items:
		var rarity = _roll_item_rarity()
		var script = _get_unique(
			func(): return ItemDatabase.get_random_item_by_rarity(rarity),
			used_item_paths
		)

		if not script:
			return false

		var instance = script.new()

		item.assign_item(
			instance.item_icon,
			instance.item_name,
			instance.item_description,
			script.resource_path,
			0,
			rarity
		)
	return true

func populate_shop(
	items: Array,
	difficulty: float,
	lowest_price_ref: Callable
) -> bool:
	var used_item_paths: Array[String] = []
	var used_heart_paths: Array[String] = []

	# Items
	for item in items:
		var rarity = _roll_item_rarity()
		var base_price = _get_item_price(rarity, difficulty)

		var script = _get_unique(
			func(): return ItemDatabase.get_random_item_by_rarity(rarity),
			used_item_paths
		)

		if not script:
			return false

		var instance = script.new()
		var price = _apply_discount(base_price)
		lowest_price_ref.call(price)

		item.assign_item(
			instance.item_icon,
			instance.item_name,
			instance.item_description,
			script.resource_path,
			price,
			price != base_price,
			rarity
		)
	return true

func _get_unique(getter: Callable, used: Array[String]):
	for i in range(MAX_ATTEMPTS):
		var script = getter.call()
		if not script:
			return null
		if script.resource_path not in used:
			used.append(script.resource_path)
			return script
	return null


func _apply_discount(base: int) -> int:
	var r = randf()
	if r <= 0.05:
		return int(base * 0.5)
	elif r <= 0.10:
		return int(base * 0.85)
	return base


func _roll_item_rarity() -> int:
	var r = randf()
	if r <= 0.05: return 4
	elif r <= 0.15: return 3
	elif r <= 0.4: return 2
	return 1

func _get_item_price(rarity: int, difficulty: float) -> int:
	match rarity:
		4: return round(50 + difficulty * 2)
		3: return round(35 + difficulty * 1.8)
		2: return round(20 + difficulty * 1.5)
		_: return round(10 + difficulty * 1.1)
