extends Node2D

var player = PlayerController
var damage: int
var armor_penetration: int
var hit_player
var duration := 1.0
var elapsed_time := 0.0


func _ready() -> void:
	scale = Vector2.ZERO  # Start at zero scale

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# Scale up smoothly to 1.0 over duration
	var t = clamp(elapsed_time / duration, 0.0, 1.0)
	scale = Vector2.ONE * t
	
	if elapsed_time >= duration:
		if hit_player:
			player.take_damage(damage, armor_penetration)
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox") and not area.is_in_group("scrimblo"):
		hit_player = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitbox") and not area.is_in_group("scrimblo"):
		hit_player = false
