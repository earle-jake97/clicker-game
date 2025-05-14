extends Node2D

var player = PlayerController
var damage: int
var armor_penetration: int
var hit_player
var duration = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.x -= randi_range(-15, 15)
	await get_tree().create_timer(duration, false).timeout
	
	if hit_player:
		player.take_damage(damage, armor_penetration)
	
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		hit_player = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		hit_player = false
