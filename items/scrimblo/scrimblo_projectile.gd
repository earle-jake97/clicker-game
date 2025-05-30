extends Node2D
var target
@onready var area_2d: Area2D = $Area2D
var direction = Vector2(0, 0)
var speed = 400
var lifetime = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	z_index = global_position.y + 100
	rotate(10 * delta)
	position += direction * speed * delta
	lifetime += delta
	if lifetime >= 5.0:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("take_damage") and area.get_parent().is_in_group("enemy"):
		area.get_parent().take_damage(PlayerController.calculate_damage().damage, DamageBatcher.DamageType.NORMAL)
		queue_free()
