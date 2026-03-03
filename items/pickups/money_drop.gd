extends Node2D

const NICKEL = preload("uid://bkcjtiy73lq51")
const DOLLAR = preload("uid://dqpe7h1ofqgab")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var value = 1
var chase_player = false
var speed = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("drop")
	if value >= 5:
		sprite_2d.texture = NICKEL
	if value >= 10:
		sprite_2d.texture = DOLLAR


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if chase_player and is_instance_valid(PlayerController.get_player_body()):
		speed += 10
		global_position = global_position.move_toward(PlayerController.get_player_body().global_position, delta * speed) 

func _on_magnet_call():
	animation_player.play("chase")
	chase_player = true

func _on_pickup_raidus_area_entered(area: Area2D) -> void:
	PlayerController.add_cash(value)
	queue_free()


func _on_magnet_radius_area_entered(area: Area2D) -> void:
	animation_player.play("chase")
	chase_player = true
