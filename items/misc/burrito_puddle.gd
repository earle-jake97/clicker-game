extends Node2D
var puddle_damage
var enemy_list = {}
var interval = 0.2
var time = 0.0
var lifetime = 0.0
const BURRITO_SCRIPT := preload("res://items/scripts/4/michaels_burrito.gd")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	lifetime += delta
	if time >= interval:
		time = 0.0
		damage_all_enemies()
	if lifetime >= 3.0:
		animation_player.play("fade")
	if lifetime >= 4.0:
		queue_free()
	if GameState.on_map_screen:
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if is_instance_valid(enemy):
		enemy_list.get_or_add(enemy)


func _on_area_2d_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	if is_instance_valid(enemy):
		enemy_list.erase(enemy)

func damage_all_enemies():
	for enemy in enemy_list.keys():
		if enemy.has_method("take_damage"):
			enemy.take_damage(puddle_damage, DamageBatcher.DamageType.BLEED)
		#else:
			#to_remove.append(enemy)
	#for enemy in to_remove:
		#enemy_list.erase(enemy)
