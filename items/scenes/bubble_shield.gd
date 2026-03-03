extends Node2D
 
var health = 25
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var modulate_player: AnimationPlayer = $ModulatePlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.bubble_shield_active = true
	
func _physics_process(delta: float) -> void:
	if is_instance_valid(PlayerController.get_player_body()):
		global_position = global_position.move_toward(PlayerController.get_player_body().global_position, delta * 2000)
	else:
		clear()

func take_damage(damage):
	health -= damage
	modulate_player.play("take_damage")
	if health <= 0:
		collision_shape_2d.disabled = true
		animation_player.play("shrink")
		await get_tree().create_timer(0.47).timeout
		clear()

func clear():
	GameState.bubble_shield_active = false
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent():
		if area.get_parent().damage:
			take_damage(area.get_parent().damage)
			area.get_parent().clear()
