extends Node2D
@onready var simon_says: Node2D = $"y_sort_node/simon says"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Exit/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var magician: Node2D = $y_sort_node/magician
const MAGICIAN_TENT_OPEN = preload("uid://uyrsssb57ucc")
const MapView = "res://map/map_scene.tscn"

var game_running = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_magician_halftime() -> void:
	animation_player.play("clowns_run")
	await get_tree().create_timer(1.0).timeout
	simon_says.turn_on()


func _on_magician_magician_dead() -> void:
	simon_says.turn_off()
	await get_tree().create_timer(5.0)
	sprite_2d.texture = MAGICIAN_TENT_OPEN
	collision_shape_2d.disabled = false


func _on_exit_area_entered(area: Area2D) -> void:
	GameState.endless_mode = true
	HealthBar.endless_sprite.visible = true
	var rand = randf()
	SceneManager.switch_to_scene(MapView)


func _on_simon_says_game_on() -> void:
	if is_instance_valid(magician):
		magician.set_simon_says(true)


func _on_simon_says_game_off() -> void:
	if is_instance_valid(magician):
		magician.set_simon_says(false)
