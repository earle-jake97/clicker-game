extends BaseEnemy

@onready var head: Sprite2D = $container/sprite/head
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const DEVON = preload("res://sprites/enemies/devil/devon.wav")
const NEW_DEVIL_HEAD = preload("res://sprites/enemies/devil/new_devil_head.png")
const NEW_DEVIL_HEAD_DEAD = preload("res://sprites/enemies/devil/new_devil_head_dead.png")
const NEW_DEVIL_HEAD_SMILE = preload("res://sprites/enemies/devil/new_devil_head_smile.png")

func extra_ready():
	knockback_strength = 500
	attack_animation_length = 0.2
	base_attack_speed = 0.35
	if SoundManager.imp_spawn_sound():
		audio_stream_player_2d.pitch_scale = pitch_scale
		audio_stream_player_2d.play()

func extra_processing(delta):
	# Handle post-attack delay
	if waiting_after_attack:
		post_attack_delay += delta
		if post_attack_delay >= attack_speed:
			waiting_after_attack = false
			head.texture = NEW_DEVIL_HEAD
			animation_player.play("walk")
			post_attack_delay = 0.0
	
func start_attack():
	head.texture = NEW_DEVIL_HEAD_SMILE
	animation_player.play("attack")

	is_attacking = true
	attack_duration = 0.0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		touching_player = true
		guarantee_hit = true
		touching_entity = area.get_parent()

	elif area.is_in_group("minion_hitbox"):
		touching_player = false
		touching_entity = area.get_parent()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if touching_entity and area.get_parent() == touching_entity:
		touching_entity = null

func extra_death_parameters():
	audio_stream_player_2d.stream = DEVON
	head.texture = NEW_DEVIL_HEAD_DEAD
