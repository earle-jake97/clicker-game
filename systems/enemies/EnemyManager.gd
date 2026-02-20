extends Node

var enemy_list: Array = []
signal optimize

func register(enemy):
	enemy_list.append(enemy)
	if enemy_list.size() == 50:
		optimize.emit()

func unregister(enemy):
	enemy_list.erase(enemy)

func get_all_enemies():
	return enemy_list

func clear_list():
	enemy_list = []
