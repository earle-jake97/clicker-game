# res://items/item_database.gd
extends Node

var items := []
var hearts := []
var starter_items := []
var item_backup
func _ready():
	register_items()

func register_items():
	# Add all items here
	items = [
		preload("res://items/scripts/1/stopwatch.gd"),
		preload("res://items/scripts/2/knife.gd"),
		preload("res://items/scripts/4/evil_stopwatch.gd"),
		preload("res://items/scripts/2/thunderbolt.gd"),
		preload("res://items/scripts/4/super_stopwatch.gd"),
		preload("res://items/scripts/2/number_fanatic.gd"),
		preload("res://items/scripts/2/clicked_cookie.gd"),
		preload("res://items/scripts/3/spring.gd"),
		preload("res://items/scripts/1/silly_teeth.gd"),
		preload("res://items/scripts/2/many_edged_sword.gd"),
		preload("res://items/scripts/1/pointy_sparkles.gd"),
		preload("res://items/scripts/1/toy_hammer.gd"),
		preload("res://items/scripts/2/icarus.gd"),
		preload("res://items/scripts/3/missing_soul.gd"),
		preload("res://items/scripts/1/first_aid_kit.gd"),
		preload("res://items/scripts/1/holey_shield.gd"),
		preload("res://items/scripts/2/bowling_ball.gd"),
		preload("res://items/scripts/2/ice_cube.gd"),
		preload("res://items/scripts/2/oil.gd"),
		preload("res://items/scripts/2/awp.gd"),
		preload("res://items/scripts/1/stat_stick.gd"),
		preload("res://items/scripts/1/bloody_syringe.gd"),
		preload("res://items/scripts/2/contaminated_syringe.gd"),
		preload("res://items/scripts/3/siphoning_soul.gd"),
		preload("res://items/scripts/4/the_meal.gd"),
		preload("res://items/scripts/2/gas_station_donut.gd"),
		preload("res://items/scripts/2/cast_iron.gd"),
		preload("res://items/scripts/4/lucky_horseshoe.gd"),
		preload("res://items/scripts/4/parrot.gd"),
		preload("res://items/scripts/3/test_item.gd"),
		preload("res://items/scripts/4/michaels_burrito.gd"),
		preload("res://items/scripts/1/rougher_times.gd"),
		preload("res://items/scripts/3/molten_lava_cake.gd"),
		preload("res://items/scripts/3/headtaker.gd"),
		preload("res://items/scripts/2/scythe.gd"),
		preload("res://items/scripts/3/scrimblo.gd"),
		preload("res://items/scripts/1/sus_shroom.gd"),
		preload("res://items/scripts/4/speedy_shoe.gd"),
		preload("res://items/scripts/2/exotic_feather.gd"),
		preload("res://items/scripts/1/moldy_boot.gd"),
		preload("res://items/scripts/3/fossilized_tooth.gd"),
		preload("res://items/scripts/1/needles.gd"),
		# preload more items here...
	]
	hearts = [
		preload("res://items/scripts/1/heart_01.gd"),
		preload("res://items/scripts/2/heart_02.gd"),
		preload("res://items/scripts/3/heart_03.gd"),
		preload("res://items/scripts/4/heart_04.gd")
	]

func get_random_item_by_rarity(rarity: int):
	var filtered = items.filter(func(i): return i.new().rarity == rarity)
	var item_choice
	if filtered.size() > 0:
		item_choice = filtered.pick_random()  
	else: return load("res://items/scripts/1/slop.gd")
	remove_item(item_choice)
	return item_choice

func get_starter_items():
	if starter_items.is_empty():
		return null
	return starter_items.pop_back()

func get_random_heart_by_rarity(rarity: int):
	var filtered = hearts.filter(func(i): return i.new().rarity == rarity)
	return filtered.pick_random() if filtered.size() > 0 else null

func get_random_item():
	var item_choice = items.pick_random()
	remove_item(item_choice)
	return item_choice

func reset_items():
	items = []
	register_items()

func add_item(script:Script):
	items.append(script)

func remove_item(script: Script):
	if script in items:
		items.erase(script)
