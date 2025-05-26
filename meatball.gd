extends Node2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
var rotation_speed := 0.0
var rotation_direction := 1.0
var start_pos: Vector2
var damage: float
var player: Node
var time := 0.0
var duration
var hit := false
var target_pos: Vector2
@export var speed: float = 50.0
var arc_height
var called = false

var enemy_list = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_pos = Vector2(randf_range(start_pos.x - 200, start_pos.x + 200), randf_range(start_pos.y - 30, start_pos.y + 30))
	duration = randf_range(0.3, 0.5)
	arc_height = randf_range(200, 600.0)
	collision_shape_2d.disabled = true
	rotation_speed = randf() * 300
	var dir = randf()
	if dir >= .5:
		rotation_direction = -1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	z_index = global_position.y
	time += delta
	var t = clamp(time / duration, 0, 1)

	var p0 = start_pos
	var p1 = (start_pos + target_pos) / 2 - Vector2(0, arc_height)
	var p2 = target_pos

	# Quadratic Bézier interpolation
	var pos = (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2
	global_position = pos
	rotation += rotation_direction * rotation_speed * delta
	if t >= 0.6:
		collision_shape_2d.disabled = false
	if t >= 1.0:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		queue_free()
