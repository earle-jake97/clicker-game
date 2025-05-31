extends Node2D

var player = PlayerController
var damage: int
var armor_penetration: int
var hit_player
var duration := 1.5
var elapsed_time := 0.0
var post_time = 0.0
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var puddle: Sprite2D = $puddle
@onready var lightning: Sprite2D = $lightning
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lightning_anim: AnimationPlayer = $lightning_anim
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
signal sound


func _ready() -> void:
	connect("sound", Callable(self, "_play_sound"))
	animation_player.play("puddle_grow")
	await get_tree().create_timer(1.4).timeout
	sound.emit()

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# Scale up smoothly to 1.0 over duration
	var t = clamp(elapsed_time / duration, 0.0, 1.0)
	scale = Vector2.ONE * t
	if elapsed_time >= 1.5:
		gpu_particles_2d.emitting = false
	
	if elapsed_time >= duration and not post_time > 0:
		lightning_anim.play("strike")
		post_time += delta
		animation_player.play("puddle_fade")
		if hit_player:
			player.take_damage(damage, 0)
	if post_time >= 0.05:
		lightning.visible = false
	if post_time >= 3.0:
		queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox") and not area.is_in_group("scrimblo"):
		hit_player = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hitbox") and not area.is_in_group("scrimblo"):
		hit_player = false

func _play_sound():
	audio_stream_player_2d.play()
