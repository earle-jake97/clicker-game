extends Node2D

@export var speed: float = 300.0
@export var arc_height: float = 550.0
@export var max_bounces: int = 3

var rotation_speed := 0.0
var rotation_direction := 1.0
var start_pos: Vector2
var target: Node
var bounce_index: int = 0
var hit_chain: Array = []
var damage: float
var crit: bool
var player: Node
var time := 0.0
var duration := 0.5
var hit := false
var target_pos: Vector2

func _ready():
	for item in player.inventory:
		if "bounce_extend" in item.tags:
			max_bounces += item.occurrences
	arc_height = randi_range(arc_height - 40, arc_height + 40)
	duration = randf_range(duration - 0.05, duration + 0.05)
	rotation_direction = -1.0 if randf() < 0.5 else 1.0
	rotation_speed = randf_range(1.0, 40.0)

	if is_instance_valid(target):
		hit_chain.append(target)
		if target.is_inside_tree():
			target_pos = target.global_position
		else:
			target_pos = start_pos + Vector2(100, -100)
	else:
		target_pos = start_pos + Vector2(100, -100)

func _process(delta):
	time += delta
	var t = clamp(time / duration, 0, 1)

	var p0 = start_pos
	var p1 = (start_pos + target_pos) / 2 - Vector2(0, arc_height)
	var p2 = target_pos

	# Quadratic Bézier interpolation
	var pos = (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2
	global_position = pos
	rotation += rotation_direction * rotation_speed * delta

	if t >= 1.0 and not hit:
		hit = true

		# Safe check before accessing target
		if is_instance_valid(target) and target.is_inside_tree():
			if target.has_method("take_damage") and target.health > 0:
				target.take_damage(round(damage), crit)
				if player and player.has_method("proc_items"):
					player.proc_items(target)

		# Attempt to bounce
		if bounce_index < max_bounces:
			var next_target = get_next_bounce_target()
			if next_target:
				var new_proj = preload("res://items/misc/nubby_projectile.tscn").instantiate()
				new_proj.global_position = Vector2(-10000, -10000)
				new_proj.start_pos = global_position
				new_proj.target = next_target
				new_proj.bounce_index = bounce_index + 1
				new_proj.hit_chain = hit_chain.duplicate()
				new_proj.damage = damage * 1.3
				new_proj.player = player
				get_tree().current_scene.add_child(new_proj)

		queue_free()

func get_next_bounce_target() -> Node:
	var valid_targets = []
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and enemy != target and enemy not in hit_chain and enemy.is_inside_tree():
			if enemy.health > 0:
				valid_targets.append(enemy)

	if valid_targets.is_empty():
		if hit_chain.size() > 0:
			var previous_target = hit_chain[0]
			if is_instance_valid(previous_target) and previous_target.health > 0:
				return previous_target
			else:
				return target
		else:
			return target

	return valid_targets[randi() % valid_targets.size()]
