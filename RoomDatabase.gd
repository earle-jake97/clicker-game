extends Node

enum RoomName { HORDE, TRAVERSAL, MINIBOSS, SHOP, ITEM, TIMER, DUMMY, BOSS, SECRET_SHOP }

const ROOM_SCENES := {
	RoomName.HORDE: "res://systems/map/horde_scenes/horde_1_map.tscn",
	RoomName.TRAVERSAL: "res://systems/map/horde_scenes/horde_1_map.tscn",
	RoomName.MINIBOSS: "res://systems/map/horde_scenes/horde_1_map.tscn",
	RoomName.SHOP: "res://systems/shop/shop.tscn",
	RoomName.ITEM: "res://systems/shop/item_room.tscn",
	RoomName.TIMER: "res://systems/map/horde_scenes/horde_map_1_timed.tscn",
	RoomName.DUMMY: "res://systems/map/loot_dummy.tscn",
	RoomName.BOSS: "res://systems/map/boss_scenes/boss_1_map.tscn",
	RoomName.SECRET_SHOP: "res://systems/shop/secret_shop.tscn"
}

const ROOM_NAMES := {
	RoomName.HORDE: "Horde",
	RoomName.TRAVERSAL: "Traversal",
	RoomName.MINIBOSS: "Miniboss",
	RoomName.SHOP: "Shop",
	RoomName.ITEM: "Item",
	RoomName.TIMER: "Time Attack",
	RoomName.DUMMY: "Bonus Room",
	RoomName.BOSS: "Boss",
	RoomName.SECRET_SHOP: "Bonus Room"
}

const ROOM_DESCRIPTIONS := {
	RoomName.HORDE: "Kill all enemies before moving on.",
	RoomName.TRAVERSAL: "Get to the end and grab the treasure!",
	RoomName.MINIBOSS: "A miniboss stands in your way.",
	RoomName.SHOP: "Visit the shop!",
	RoomName.ITEM: "Grab a free item!",
	RoomName.TIMER: "Survive an endless onslaught until time runs out.",
	RoomName.DUMMY: "A strange room awaits you...",
	RoomName.BOSS: "The boss of this realm stands in your way.",
	RoomName.SECRET_SHOP: "A strange room awaits you..."
}

const ROOM_SPRITES := {
	RoomName.HORDE: preload("res://map/icons/horde.png"),
	RoomName.TRAVERSAL: preload("res://map/icons/traversal.png"),
	RoomName.MINIBOSS: preload("res://map/icons/miniboss.png"),
	RoomName.SHOP: preload("res://map/icons/shop.png"),
	RoomName.ITEM: preload("res://map/icons/item.png"),
	RoomName.TIMER: preload("res://map/icons/timer.png"),
	RoomName.DUMMY: preload("res://map/icons/secret.png"),
	RoomName.BOSS: preload("res://map/icons/boss.png"),
	RoomName.SECRET_SHOP: preload("res://map/icons/secret.png")
}

func get_scene_for_room(room_type: int) -> String:
	return ROOM_SCENES.get(room_type, "")

func get_room_name(room_type: int) -> String:
	return ROOM_NAMES.get(room_type)

func get_sprite_for_room(room_type: int):
	return ROOM_SPRITES.get(room_type)
	
func get_description_for_room(room_type: int):
	return ROOM_DESCRIPTIONS.get(room_type)
