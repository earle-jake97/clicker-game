extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector2(-10000, -10000)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func target_enemy(enemy):
	global_position = get_crosshair_position(enemy)

func hide_crosshair():
	global_position = Vector2(-10000, -10000)


func get_crosshair_position(enemy) -> Vector2:
	var crosshair_node = enemy.find_child("crosshair", 1, 1)
	if crosshair_node:
		return crosshair_node.global_position
	else:
		return enemy.global_position
