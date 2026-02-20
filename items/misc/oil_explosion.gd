extends Node2D

const smoke_scene = preload("res://items/misc/smoke_cloud.tscn")
@export var cloud_count := 5
@onready var explosion: AnimatedSprite2D = $explosion
var enemy
var explosion_damage
func _ready():
	scale = GameState.get_size_modifier()
	explosion.play("explode")
	if EnemyManager.get_all_enemies().size() >= 50:
		explosion.visible = false
		for i in range(cloud_count):
			var cloud = smoke_scene.instantiate()
			add_child(cloud)
			cloud.global_position = global_position
	# Auto-destroy the explosion node after a short delay
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	enemy = area.get_parent()
	if enemy.get_groups().has("enemy") and enemy.has_method("take_damage"):
			enemy.take_damage(round(explosion_damage), DamageBatcher.DamageType.NORMAL, "Oil Explosion")
