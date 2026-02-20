extends Node2D
@onready var _1: AnimatedSprite2D = $"1"
@onready var _2: AnimatedSprite2D = $"2"
@onready var _3: AnimatedSprite2D = $"3"
@onready var navigation_region_2d: NavigationRegion2D = $".."


const COST = 10
const DIVING = preload("uid://dxjqsycd2o1db")
const DEVIL = preload("uid://c46jces8nqyq6")

var slot_1 = 0
var slot_2 = 0
var slot_3 = 0

var can_gamble = true

func gamble():
	can_gamble = false
	PlayerController.add_cash(-COST)
	_1.play("roll")
	await get_tree().create_timer(0.2).timeout
	_2.play("roll")
	await get_tree().create_timer(0.2).timeout
	_3.play("roll")
	slot_1 = roll_slot()
	slot_2 = roll_slot()
	slot_3 = roll_slot()
	await get_tree().create_timer(1.0).timeout
	set_slots()

func get_slot_sprite(value):
	if value == 1:
		return "7"
	if value == 2:
		return "spam"
	if value == 3:
		return "bad"

func set_slots():
	_1.play(get_slot_sprite(slot_1))
	await get_tree().create_timer(1).timeout
	_2.play(get_slot_sprite(slot_2))
	await get_tree().create_timer(1).timeout
	_3.play(get_slot_sprite(slot_3))
	give_reward()
	can_gamble = true

func give_reward():
	if slot_1 == slot_2 and slot_2 == slot_3:
		if slot_1 == 3:
			spawn_enemy()
		elif slot_1 == 1:
			PlayerController.add_cash(COST * 10)

func spawn_enemy():
	var enemy = DIVING.instantiate()
	var chosen_pos = global_position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
	enemy.target_pos = chosen_pos
	enemy.shadow_position = chosen_pos
	enemy.global_position = Vector2(chosen_pos.x, randf_range(-2500, -3500 ))
	enemy.speed = 2000
	enemy.health = 10000
	get_tree().current_scene.get_node("y_sort_node").add_child(enemy)

func roll_slot():
	var roll = randf_range(0, 1)
	if roll <= 0.45:
		return 1
	if roll <= 0.55:
		return 2
	else:
		return 3


func _on_timer_timeout() -> void:
	can_gamble = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if can_gamble and PlayerController.cash >= COST:
		gamble()
