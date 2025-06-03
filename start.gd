extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.on_start_screen = true
	TestPlayer.visible = false
	HealthBar.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	GameState.on_start_screen = false
	HealthBar.visible = true
	TestPlayer.visible = true
	SceneManager.switch_to_scene("res://map/map_view.tscn")
