extends Node2D

@export var lifespan: float = 0.2
@export var points: int = 6
@export var jaggedness: float = 30.0

@onready var line

var timer: float = 0.0

func setup(start_pos: Vector2, end_pos: Vector2):
	line = $Line2D

	# Optional Y offset to raise the lightning above the feet
	var vertical_offset = -40.0
	start_pos.y += vertical_offset
	end_pos.y += vertical_offset
	z_index = start_pos.y - 1

	# Determine left and right so we can offset outward
	if start_pos.x < end_pos.x:
		start_pos.x -= 50.0  # move left
		end_pos.x -= 40.0    # move right
	else:
		start_pos.x += 50.0  # move right
		end_pos.x += 40.0    # move left

	# Center the effect on the midpoint
	var midpoint = start_pos.lerp(end_pos, 0.5)
	global_position = midpoint

	# Convert points to local space
	start_pos = to_local(start_pos)
	end_pos = to_local(end_pos)

	# Build lightning path
	var lightning_points: Array = []
	var direction = (end_pos - start_pos).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)

	for i in range(points + 1):
		var t = i / float(points)
		var point = start_pos.lerp(end_pos, t)
		var offset = perpendicular * randf_range(-jaggedness, jaggedness) * (1.0 - abs(t - 0.5) * 2.0)
		point += offset
		lightning_points.append(point)

	line.points = lightning_points


func _process(delta):
	timer += delta
	if timer >= lifespan:
		queue_free()
		return

	var remaining = 1.0 - (timer / lifespan)
	line.modulate.a = remaining

	# Slight jitter/flicker
	for i in range(line.points.size()):
		var p = line.points[i]
		p += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
		line.set_point_position(i, p)
