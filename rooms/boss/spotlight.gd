extends PointLight2D

var stiffness = 12.0
var damping = 4.0
var max_speed = 2000

var velocity = Vector2.ZERO
@export var target: Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		if is_instance_valid(PlayerController.get_player_body()):
			target = PlayerController.get_player_body()
		return
	
	var displacement = target.global_position - global_position
	
	var force = displacement * stiffness
	
	force -= velocity * damping
	
	velocity += force * delta
	
	velocity = velocity.limit_length(max_speed)
	
	global_position += velocity * delta

func set_target(set_target):
	target = set_target
