extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_valid(area.get_parent()):
		var target = area.get_parent()
		var direction = target.global_position - global_position
		var params = [direction, 1000.0, true]
		target.take_damage(20, 0, true, params)
