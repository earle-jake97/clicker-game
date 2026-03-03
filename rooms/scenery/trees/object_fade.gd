extends StaticBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	animation_player.play("fade_out")


func _on_area_2d_area_exited(area: Area2D) -> void:
	animation_player.play("fade_in")
