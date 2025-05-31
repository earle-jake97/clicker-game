extends Node2D

var smoke_timer = 0.0
var smoke_spawn = 0.01
const smoke_scene = preload("res://items/misc/smoke_cloud.tscn")
const pebble_scene = preload("res://items/misc/pebble.tscn")
var map
var chosen_pos
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	smoke_timer += delta
	if smoke_timer >= smoke_spawn:
		smoke_timer = 0
		var cloud = smoke_scene.instantiate()
		var pebble = pebble_scene.instantiate()
		add_child(cloud)
		add_child(pebble)
		var offset_x = randf_range(-100, 200)
		var offset_y = randf_range(-30, 30)
		pebble.scale = Vector2(1.2, 1.2)
		pebble.global_position = global_position + Vector2(offset_x, offset_y)
		pebble.z_index = cloud.global_position.y
		cloud.animation_player.stop()
		cloud.scale = Vector2(1.2, 1.2)
		cloud.global_position = global_position + Vector2(offset_x, offset_y)
		cloud.z_index = cloud.global_position.y

	global_position = global_position.move_toward(Vector2(-300, chosen_pos.y), 700 * delta)

	
	if global_position.x <= -200:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_groups().has("player_hitbox") and area.get_parent().is_in_group("main"):
		PlayerController.take_damage(20, 5)
	if area.is_in_group("scrimblo") and area.get_parent().has_meta("take_damage"):
		area.get_parent().take_damage(20, 5)
