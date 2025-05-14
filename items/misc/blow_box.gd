extends Node2D
var strength = 1
var lifetime = 3.0
var timer = 0.0
var spawn_particle_time = 0.15
var particle_timer = 0.0
@onready var marker_2d: Marker2D = $Marker2D
const WISP_PROJECTILE = preload("res://items/misc/wisp_projectile.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer >= lifetime:
		queue_free()
	timer += delta
	particle_timer += delta
	if particle_timer >= spawn_particle_time:
		spawn_wind()
		particle_timer = 0.0 + randf_range(-0.1, 0.1)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("push_back"):
		area.get_parent().push_back(strength)

func spawn_wind():
	var wind_scene = WISP_PROJECTILE.instantiate()
	var pos = marker_2d.global_position
	wind_scene.speed += randf_range(-20.0, 20.0)
	pos += Vector2(0, randi_range(-30, 30))
	wind_scene.initial_position = pos
	wind_scene.global_position = pos
	add_child(wind_scene)
