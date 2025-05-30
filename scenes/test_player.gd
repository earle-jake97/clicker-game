extends Node2D
var dead = false
@onready var head: Sprite2D = $sprite/body/head
var player = PlayerController
const HEAD = preload("res://sprites/test_player/head.png")
const HEAD_NORMAL = preload("res://sprites/test_player/head_normal.png")
const HEAD_PAIN = preload("res://sprites/test_player/head_pain.png")
const HEAD_DIRE = preload("res://sprites/test_player/head_dire.png")
const HEAD_DEAD = preload("res://sprites/test_player/head_dead.png")
const BODY_DIRE = preload("res://sprites/test_player/body_dire.png")
const BODY_DEAD = preload("res://sprites/test_player/body_dead.png")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arms: AnimatedSprite2D = $sprite/body/arms
@onready var body: Sprite2D = $sprite/body

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.animation_set_next("move_up", "idle")
	animation_player.animation_set_next("move_down", "idle")
	animation_player.animation_set_next("die", "dead")
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerController.clicks_per_second >= 20:
		arms.play("gun")
		arms.set_speed_scale(1.0)
	elif PlayerController.clicks_per_second >= 15:
		arms.set_speed_scale(1.2)
	elif PlayerController.clicks_per_second >= 10:
		arms.set_speed_scale(1.2)

	z_index = round(global_position.y)
	var percentage = float(player.current_hp) / player.max_hp
	if player.current_hp <= 0:
		dead = true
		arms.play("die")
		animation_player.play("die")
		head.texture = HEAD_DEAD
		body.texture = BODY_DEAD
		PlayerController.paused = true
	elif percentage <= 0.10:
		head.texture = HEAD_DIRE
		body.texture = BODY_DIRE
	elif percentage < 0.30:
			head.texture = HEAD_PAIN
	elif percentage < 0.60:
		head.texture = HEAD_NORMAL
	elif percentage >= 0.60:
		head.texture = HEAD

func is_alive():
	return true
