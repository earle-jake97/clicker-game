extends Node2D
var min_scale = Vector2.ZERO
var max_scale = Vector2.ONE
var max_distance = 1000
var enemy_ref: Node2D = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemy_ref == null:
		queue_free()
		return
	var dist = global_position.distance_to(enemy_ref.global_position)
	var t = clamp(1.0 - dist / max_distance, 0.0, 1.0)
	scale = min_scale.lerp(max_scale, t)
