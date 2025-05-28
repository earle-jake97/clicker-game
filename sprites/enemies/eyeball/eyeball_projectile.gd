extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position.move_toward(TestPlayer.global_position, 500 * delta)
	z_index = global_position.y - 1
	
	look_at(TestPlayer.global_position)
	rotation += deg_to_rad(180)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		PlayerController.take_damage(1, 0)
		queue_free()

func destroy_projectile():
	queue_free()
