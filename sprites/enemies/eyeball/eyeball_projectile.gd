extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var target = TestPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for entity in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(entity):
			continue
		
		var distance = global_position.distance_to(entity.global_position)

		var is_closer = true
		if is_instance_valid(target):
			is_closer = distance < global_position.distance_to(target.global_position)
		
		if entity.has_method("is_alive") and entity.is_alive() and is_closer and entity.global_position.x <= global_position.x:
			target = entity
		else:
			target = TestPlayer

	global_position = global_position.move_toward(target.global_position, 500 * delta)
	z_index = global_position.y - 1
	
	look_at(target.global_position)
	rotation += deg_to_rad(180)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		if target.has_method("take_damage"):
			target.take_damage(1, 0)
		else:
			PlayerController.take_damage(1, 0)
		queue_free()

func destroy_projectile():
	queue_free()
