extends Node2D

@export var on = false
@onready var yellow: Sprite2D = $base/yellow
@onready var blue: Sprite2D = $base/blue
@onready var green: Sprite2D = $base/green
@onready var red: Sprite2D = $base/red
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var yellow_collider: CollisionPolygon2D = $base/yellow/yellow_area/yellow_collider
@onready var blue_collider: CollisionPolygon2D = $base/blue/blue_area/blue_collider
@onready var green_collider: CollisionPolygon2D = $base/green/green_area/green_collider
@onready var red_collider: CollisionPolygon2D = $base/red/red_area/red_collider

var minigame_timer = 15.0 
var minigame_cooldown = 22.0

var player_inside = false

signal game_on
signal game_off

var choice_1
var choice_2
var choice_3
var choice_4 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not on:
		return
	minigame_timer += delta
	if minigame_timer >= minigame_cooldown:
		minigame_timer = -5.0
		blink_all_lights()
		await get_tree().create_timer(1.2).timeout
		simon_says()

func turn_on():
	on = true
	animation_player.play("spawn")

func turn_off():
	on = false

func blink_all_lights():
	game_on.emit()
	turn_on_light_temporarily(1, 0.2)
	turn_on_light_temporarily(2, 0.2)
	turn_on_light_temporarily(3, 0.2)
	turn_on_light_temporarily(4, 0.2)
	await get_tree().create_timer(0.4).timeout
	turn_on_light_temporarily(1, 0.2)
	turn_on_light_temporarily(2, 0.2)
	turn_on_light_temporarily(3, 0.2)
	turn_on_light_temporarily(4, 0.2)
	await get_tree().create_timer(0.4).timeout
	turn_on_light_temporarily(1, 0.2)
	turn_on_light_temporarily(2, 0.2)
	turn_on_light_temporarily(3, 0.2)
	turn_on_light_temporarily(4, 0.2)
	

func simon_says():
	choice_1 = randi_range(1, 4)
	choice_2 = randi_range(1, 4)
	choice_3 = randi_range(1, 4)
	choice_4 = randi_range(1, 4)
	turn_on_light_temporarily(choice_1)
	await get_tree().create_timer(1.0).timeout
	turn_on_light_temporarily(choice_2)
	await get_tree().create_timer(1.0).timeout
	turn_on_light_temporarily(choice_3)
	await get_tree().create_timer(1.0).timeout
	turn_on_light_temporarily(choice_4)
	
	await get_tree().create_timer(3.0).timeout
	simon_says_phase_2()

func simon_says_phase_2():
	turn_on_light_and_collider(choice_1)
	await get_tree().create_timer(3.0).timeout
	turn_on_light_and_collider(choice_2)
	await get_tree().create_timer(3.0).timeout
	turn_on_light_and_collider(choice_3)
	await get_tree().create_timer(3.0).timeout
	turn_on_light_and_collider(choice_4)
	game_off.emit()

func turn_on_light_and_collider(number):
	turn_on_light_temporarily(number, 1.0)
	if number == 1:
		yellow_collider.disabled = false
	elif number == 2:
		blue_collider.disabled = false
	elif number == 3:
		green_collider.disabled = false
	else:
		red_collider.disabled = false
	await get_tree().create_timer(0.25).timeout
	if not player_inside and on:
		hurt_player()
	player_inside = false
	yellow_collider.disabled = true
	red_collider.disabled = true
	blue_collider.disabled = true
	green_collider.disabled = true

func hurt_player():
	var knockback_parameters = [Vector2.ZERO, 0, false]
	PlayerController.get_player_body().take_damage(15, 0, true, knockback_parameters)


func turn_on_light_temporarily(number, duration: float = 0.5):
	if number == 1:
		yellow.show()
	elif number == 2:
		blue.show()
	elif number == 3:
		green.show()
	else:
		red.show()
	await get_tree().create_timer(duration).timeout
	yellow.hide()
	blue.hide()
	green.hide()
	red.hide()


func _on_yellow_area_area_entered(area: Area2D) -> void:
	player_inside = true

func _on_blue_area_area_entered(area: Area2D) -> void:
	player_inside = true

func _on_green_area_area_entered(area: Area2D) -> void:
	player_inside = true

func _on_red_area_area_entered(area: Area2D) -> void:
	player_inside = true


func _on_red_area_area_exited(area: Area2D) -> void:
	player_inside = false

func _on_green_area_area_exited(area: Area2D) -> void:
	player_inside = false

func _on_blue_area_area_exited(area: Area2D) -> void:
	player_inside = false

func _on_yellow_area_area_exited(area: Area2D) -> void:
	player_inside = false
