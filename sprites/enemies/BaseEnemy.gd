extends Node2D
class_name BaseEnemy
var is_frozen = false

func stun(duration):
	is_frozen = true
	var anim_players = get_children().filter(func(child):
		return child is AnimationPlayer
	)
	for ap in anim_players:
		ap.playback_active = false  # Pause the animation
	await get_tree().create_timer(duration).timeout
	for ap in anim_players:
		ap.playback_active = true  # Resume the animation
	is_frozen = false
