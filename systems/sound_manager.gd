extends Node




var imp_spawn_timer = 0.0
var imp_spawn_cooldown = 3.0
var imp_death_cooldown = 1.5
var imp_death_timer = 0.0
var global_cooldown = 4.0
	
func _process(delta: float) -> void:
	imp_death_timer += delta
	imp_spawn_timer += delta

func imp_death_sound():
	if HealthBar.fast_forward:
		return false
	if imp_death_timer >= imp_death_cooldown:
		imp_death_timer = 0
		return true
	return false

func imp_spawn_sound():
	if HealthBar.fast_forward:
		return false
	if imp_spawn_timer >= imp_spawn_cooldown:
		imp_spawn_timer = 0
		return true
	return false

func thrower_spawn_sound():
	if HealthBar.fast_forward:
		return false
	else: return true
