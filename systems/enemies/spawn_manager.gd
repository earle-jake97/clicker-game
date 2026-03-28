extends Node

const DEVIL = preload("uid://ducyvw4p4i56c")
const PROJECTILE_DEMON = preload("uid://dbfgo5uaeo76m")
const IMP = preload("uid://b43cnfq107mjk")
const EYEBALL_ENEMY = preload("uid://t8ttvohfehwf")
const GHOST = preload("uid://px47tge8r383")
const DEVIL_BOSS = preload("uid://27xngsos4sod")

var spawn_handler
var all_spawners = []
var active_spawners = []

var spawns = [
	{DEVIL: 12, PROJECTILE_DEMON: 1},
	{DEVIL: 15, PROJECTILE_DEMON: 1, EYEBALL_ENEMY: 1},
	{DEVIL: 12, PROJECTILE_DEMON: 2},
	{DEVIL: 8, PROJECTILE_DEMON: 1, EYEBALL_ENEMY: 1, IMP: 5},
	{DEVIL: 12, PROJECTILE_DEMON: 1, EYEBALL_ENEMY: 2, IMP: 5},
	{DEVIL: 12, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 5},
	{DEVIL: 12, PROJECTILE_DEMON: 1, EYEBALL_ENEMY: 1, IMP: 12},
	{DEVIL: 12, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 1, IMP: 8},
	{DEVIL: 12, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 8},
	{DEVIL: 12, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 8, GHOST: 2},
	{DEVIL: 12, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 8, GHOST: 4},
	{DEVIL: 16, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 12, GHOST: 4},
	{DEVIL: 16, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 12, GHOST: 5},
	{DEVIL: 20, PROJECTILE_DEMON: 2, EYEBALL_ENEMY: 2, IMP: 20, GHOST: 4},
	

]

func init_spawner(spawner):
	all_spawners.append(spawner)

func get_enemies_for_round(round):
	var enemy_list = []
	
	var round_data
	if round - 1 >= spawns.size():
		round_data = get_default_round()
	else:
		round_data = spawns[round - 1]
	
	for enemy_type in round_data:
		var count = round_data[enemy_type]
		for i in range(count):
			enemy_list.append(enemy_type)
			
	return enemy_list

func get_default_round():
	var default_spawns = {
		DEVIL: PlayerController.difficulty,
		PROJECTILE_DEMON: floor(PlayerController.difficulty / 4), 
		EYEBALL_ENEMY: floor(PlayerController.difficulty / 4), 
		IMP: floor(PlayerController.difficulty / 3), 
		GHOST: floor(PlayerController.difficulty / 4)
		}
	return default_spawns

func add_spawner(spawner):
	if spawner in active_spawners:
		return
	else:
		active_spawners.append(spawner)

func remove_spawner(spawner):
	if spawner in active_spawners:
		active_spawners.erase(spawner)

func set_spawn_handler(handler):
	spawn_handler = handler

func clear_all_spawners():
	for node in all_spawners:
		node.clear()
	all_spawners = []
	active_spawners = []
