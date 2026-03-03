extends Control

var target: Node2D
var margin := 32.0
@onready var arrow: TextureRect = $Arrow

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	if target.dead:
		queue_free()
		return
	
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	
	if camera == null:
		return
		
	var screen_size = viewport.get_visible_rect().size
	var screen_center = screen_size / 2.0
	
	var camera_center = camera.get_screen_center_position()
	var world_offset = target.global_position - camera_center
	
	world_offset *= camera.zoom
	
	var enemy_screen_pos = screen_center + world_offset
	
	if Rect2(Vector2.ZERO, screen_size).has_point(enemy_screen_pos):
		visible = false
		return
	else:
		visible = true
	
	var dir = (enemy_screen_pos - screen_center).normalized()
	
	var half_size = screen_center - Vector2(margin, margin)
	
	var scale_x = half_size.x / abs(dir.x) if dir.x != 0 else INF
	var scale_y = half_size.y / abs(dir.y) if dir.y != 0 else INF

	var distance = min(scale_x, scale_y)
	
	global_position = screen_center + dir * distance
	arrow.rotation = dir.angle()
