extends Node2D

var lifetime = 5.0
var timer = 0.0
var damage = 15
var speed = 300.0
var direction = Vector2.RIGHT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	timer += delta
	global_position += delta * speed * direction
	if lifetime <= timer:
		clear()

func clear():
	queue_free()



func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_valid(area.get_parent()) and area.get_parent().has_method("take_damage"):
		var knockback_parameters = [direction, 200, false]
		area.get_parent().take_damage(damage, 0, true, knockback_parameters)
		
		clear()
