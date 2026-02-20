extends Node2D
var target_position: Vector2
var speed = 1500.0
var on_reach: Callable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var reached = false
var damage
var can_proc = true
var single_target
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
	# Call the damage function
	if on_reach:
		on_reach.call()

	# Hide the projectile sprite and play explosion
	animated_sprite_2d.play("explode")
	# Connect to the animation finished signal to free the projectile
	animated_sprite_2d.animation_finished.connect(_on_explosion_finished)
	
func _on_explosion_finished():
	queue_free()

func disable_collision(layer):
	return

func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	while enemy and is_instance_valid(enemy) and not enemy.is_in_group("enemy"):
		enemy = enemy.get_parent()
	if enemy.has_method("take_damage") and enemy.is_in_group("enemy"):
		collision_shape_2d.disabled = true
		area_2d.monitoring = false
		reached = true
		enemy.take_damage(damage.damage, damage.crit, "Player Attack")
		if can_proc:
			PlayerController.proc_items(enemy)
		animated_sprite_2d.play("explode")
		animated_sprite_2d.animation_finished.connect(_on_explosion_finished)
