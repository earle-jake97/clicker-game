extends Node2D
var target_position: Vector2
var speed = 1500.0
var on_reach: Callable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var reached = false
var damage
var can_proc = true
var single_target
var original_target
var has_damaged = false
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _ready():
	if not target_position:
		queue_free()

func _process(delta):
	if reached or not target_position:
		return
	var direction = (target_position - global_position)
	var distance_to_move = speed * delta
	if direction.length() <= distance_to_move:
		global_position = target_position
		reached = true
		_trigger_damage_and_explode()
	else:
		global_position += direction.normalized() * distance_to_move

func _trigger_damage_and_explode():
	if has_damaged:
		return

	# If we reached destination without collision,
	# damage original target instead
	if is_instance_valid(original_target):
		_deal_damage(original_target)
	else:
		_explode()

func _explode():
	collision_shape_2d.disabled = true
	area_2d.monitoring = false
	
	animated_sprite_2d.play("explode")
	animated_sprite_2d.animation_finished.connect(_on_explosion_finished)
	
func _on_explosion_finished():
	queue_free()

func _deal_damage(enemy):
	if has_damaged:
		return
	has_damaged = true
	reached = true
	
	if is_instance_valid(enemy):
		enemy.take_damage(damage.damage, damage.crit, "Player Attack")
		if can_proc:
			PlayerController.proc_items(enemy)
	_explode()

func disable_collision(layer):
	return

func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	while enemy and is_instance_valid(enemy) and not enemy.is_in_group("enemy"):
		enemy = enemy.get_parent()

	if is_instance_valid(enemy) and enemy.has_method("take_damage"):
		collision_shape_2d.disabled = true
		area_2d.monitoring = false
		_deal_damage(enemy)
