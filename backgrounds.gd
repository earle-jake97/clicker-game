extends Node

const BACKGROUND_1 = preload("res://world1/background1.png")
const BACKGROUND_2 = preload("res://world1/background2.png")
const BACKGROUND_3 = preload("res://world1/background3.png")
const BACKGROUND_4 = preload("res://world1/background4.png")


const world_1 = [BACKGROUND_1, BACKGROUND_2, BACKGROUND_3, BACKGROUND_4]

func get_random_background():
	var ran = randi_range(0, world_1.size()-1)
	
	return world_1[ran]
