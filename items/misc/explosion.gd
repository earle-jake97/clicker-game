extends Node2D

const smoke_scene = preload("res://items/misc/smoke_cloud.tscn")
@export var cloud_count := 5
@onready var explosion: AnimatedSprite2D = $explosion

func _ready():
	scale = GameState.get_size_modifier()
	explosion.play("explode")
	for i in range(cloud_count):
		var cloud = smoke_scene.instantiate()
		add_child(cloud)
		cloud.global_position = global_position + Vector2(-50, -50)

	# Auto-destroy the explosion node after a short delay
	await get_tree().create_timer(1.5).timeout
	queue_free()
