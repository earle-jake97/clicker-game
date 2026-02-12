extends Node2D
var target_position: Vector2
var speed = 1500.0
var on_reach: Callable
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var reached = false

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
	
