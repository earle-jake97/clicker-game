extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	SceneManager.switch_to_scene("res://systems/map/horde_scenes/horde_endless.tscn")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
