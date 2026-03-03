extends BaseEnemy
var has_hidden = false
var hiding = false
var hide_timer = 0
var hide_duration = 2.0
var health_snapshot = 0.0
@onready var body: AnimatedSprite2D = $container/sprite/body
@onready var timer: Timer = $Timer

func extra_ready():
	max_health = 250.0
	base_speed = 80.0
	damage = 10
	knockback_strength = 700
	attack_animation_length = 0.01
	base_attack_speed = 0.02

func extra_processing(delta):
	hide_timer += delta
	
	if health <= max_health/2 and not has_hidden:
		invuln(delta)
		
	if hiding and not hide_timer >= hide_duration:
		damage_cooldown = 0.0
		var t = hide_timer / hide_duration
		t = clamp(t, 0.0, 1.0)
		health = lerp(health_snapshot, max_health, t)
		if t >= 1.0:
			health = max_health
		health_bar.value = health

func move_towards_target(delta):
	if not can_move or unique_movement or spawning:
		return
	# Move toward player only if not waiting after attack
	if player and not is_attacking and post_attack_delay <= 0.01 and not dead and not is_pushed and not is_frozen and global_position.distance_to(target.global_position) >= 40.0:
		global_position = global_position.move_toward(target.global_position, speed * delta)

func invuln(delta):
	if has_hidden:
		return
	
	timer.start(hide_duration)
	hide_timer = 0
	health_snapshot = health
	EnemyManager.unregister(self)
	remove_from_group("enemy")
	has_hidden = true
	hiding = true
	body.play("hide")
	animation_player.play("hide")

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


func _on_timer_timeout() -> void:
	hiding = false
	EnemyManager.register(self)
	body.play("idle")
	
