extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	z_index = global_position.y

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_groups().has("player_hitbox") and area.get_parent().is_in_group("main"):
		PlayerController.take_damage(2, 0)
		queue_free()
		
	if area.is_in_group("scrimblo") and area.get_parent().has_meta("take_damage"):
		area.get_parent().take_damage(3, 0)
		queue_free()
