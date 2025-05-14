extends Node2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
const NEW_PLAYER_DEAD = preload("res://sprites/test_player/new_player_dead.png")
var dead = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.animation_set_next("move_up", "idle")
	animation_player.animation_set_next("move_down", "idle")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	z_index = round(global_position.y)
	if PlayerController.current_hp <= 0:
		dead = true
		animation_player.pause()
		sprite_2d.texture = NEW_PLAYER_DEAD
		PlayerController.paused = true
