extends BaseEnemy

var exploded = false
var post_death_explosion = false
@onready var pie_pos: Marker2D = $container/sprite/body/pie/pie_pos
const CLOWN_EXPLOSION = preload("uid://c2k7a5h1qbeer")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func extra_ready():
	max_health = 250.0
	base_speed = 120.0
	damage = 0
	value = 0
	item_rolled = true
	
func explode():
	if exploded:
		return
	exploded = true
	animation_player.play("fall")
	await get_tree().create_timer(0.556).timeout
	health = 0

func extra_death_parameters():
	if not post_death_explosion:
		post_death_explosion = true
		var explosion = CLOWN_EXPLOSION.instantiate()
		explosion.global_position = pie_pos.global_position
		get_tree().current_scene.get_node("y_sort_node").add_child(explosion)
		audio_stream_player_2d.play()

func _on_area_2d_area_entered(area: Area2D) -> void:
	explode()
