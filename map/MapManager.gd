extends Node
class_name map_manager_class
enum RoomCategory { COMBAT, POWERUP, BONUS, VARIED, VARIED_NO_ITEM, DANGER, ENDLESS }
enum RoomName { HORDE, TRAVERSAL, MINIBOSS, SHOP, ITEM, TIMER, DUMMY, BOSS, SECRET_SHOP }
var round = 1
var world = 1

var category_to_types = {
	RoomCategory.COMBAT: 
		[RoomName.HORDE, RoomName.TRAVERSAL],
	
	RoomCategory.POWERUP: 
		[RoomName.SHOP, RoomName.ITEM],
	
	RoomCategory.VARIED: 
		[RoomName.HORDE, RoomName.TRAVERSAL, RoomName.MINIBOSS, RoomName.ITEM, 
		RoomName.SHOP, RoomName.SECRET_SHOP, RoomName.DUMMY, RoomName.TIMER],
		
	RoomCategory.VARIED_NO_ITEM:
		[RoomName.HORDE, RoomName.TRAVERSAL, RoomName.MINIBOSS, RoomName.SECRET_SHOP, 
		RoomName.DUMMY, RoomName.TIMER],
		
	RoomCategory.DANGER:
		[RoomName.MINIBOSS, RoomName.TIMER, RoomName.MINIBOSS, RoomName.TIMER, RoomName.HORDE],
	RoomCategory.ENDLESS:
		[RoomName.HORDE, RoomName.TRAVERSAL, RoomName.MINIBOSS, RoomName.ITEM, 
		RoomName.SHOP, RoomName.SECRET_SHOP, RoomName.DUMMY, RoomName.TIMER, RoomName.BOSS]
}

func pick_room_for_category(category: RoomCategory):
	return category_to_types[category].pick_random()

func reset_defaults():
	round = 1
	world = 1
