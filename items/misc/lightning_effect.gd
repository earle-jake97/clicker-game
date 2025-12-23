extends Node2D

@export var lifespan: float = 0.2
@export var points: int = 6
@export var jaggedness: float = 30.0

@onready var line

var timer: float = 0.0

func setup(start_pos: Vector2, end_pos: Vector2, procs: bool = false):
	line = $Line2D
	line.position = Vector2.ZERO
	line.rotation = 0
	line.scale = Vector2.ONE

	# Position node at start (simpler + more stable)
	global_position = start_pos

	# Convert end into local space relative to start
	var local_start := Vector2.ZERO
	var local_end := to_local(end_pos)

	z_index = -4000

	var lightning_points: Array = []
	var direction = (local_end - local_start).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)

	for i in range(points + 1):
		var t = i / float(points)
		var point = local_start.lerp(local_end, t)

		# DO NOT offset endpoints
		if i != 0 and i != points:
			var strength = 1.0 - abs(t - 0.5) * 2.0
			point += perpendicular * randf_range(-jaggedness, jaggedness) * strength

		lightning_points.append(point)

	line.points = lightning_points
	line.default_color = Color.WHITE
	line.width = 2

	if procs:
		line.width = 3
		line.default_color = Color.CYAN

func _process(delta):
	timer += delta
	if timer >= lifespan:
		queue_free()
		return

	var remaining = 1.0 - (timer / lifespan)
	line.modulate.a = remaining

	# Jitter only interior points
	for i in range(1, line.points.size() - 1):
		var p = line.points[i]
		p += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
		line.set_point_position(i, p)
