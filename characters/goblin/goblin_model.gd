extends CharacterBody2D
var dead = false
@onready var head: Sprite2D = $sprite/body/head
var player = PlayerController
const HEAD = preload("res://sprites/player_character/goblin/head_healthy.png")
const HEAD_NORMAL = preload("res://sprites/player_character/goblin/head_healthy.png")
const HEAD_PAIN = preload("res://sprites/player_character/goblin/head_healthy.png")
const HEAD_DIRE = preload("res://sprites/player_character/goblin/head_dire.png")
const HEAD_DEAD = preload("res://sprites/player_character/goblin/head_dead.png")
const BODY_DIRE = preload("res://sprites/player_character/goblin/body_dire.png")
const BODY_DEAD = preload("res://sprites/player_character/goblin/body_dead.png")
const BODY_NORMAL = preload("res://sprites/player_character/goblin/body.png")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arms: AnimatedSprite2D = $sprite/body/arms
@onready var body: Sprite2D = $sprite/body
@onready var shadow: Sprite2D = $shadow
@onready var slingshot_origin: Marker2D = $sprite/body/arms/slingshot_origin
@onready var eyes: AnimatedSprite2D = $sprite/body/head/eyes
@onready var mouth: AnimatedSprite2D = $sprite/body/head/mouth
@onready var blink_timer: Timer = $timers/blink
@onready var iframes: Timer = $timers/iframes
@onready var modulate_player: AnimationPlayer = $ModulatePlayer
var damage_taken = false
var external_velocity = Vector2.ZERO
var external_drag = 1800.0
var blinking = false
var knockback_cooldown_active = false


@export var base_speed := 180.0
var speed := base_speed
var facing_right = true



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerController.set_player(self)
	PlayerController.player_damage_taken.connect(_on_damage_taken)
	animation_player.animation_set_next("move_up", "idle")
	animation_player.animation_set_next("move_down", "idle")
	animation_player.animation_set_next("die", "dead")
	blink_timer.start()
	
	
func _physics_process(delta: float) -> void:
	if dead:
		return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("up"):
		dir.y -= 1
	if Input.is_action_pressed("down"):
		dir.y += 1
	if Input.is_action_pressed("left"):
		dir.x -= 1
	if Input.is_action_pressed("right"):
		dir.x += 1

	if player.attacking and PlayerController.get_nearest_enemy():
		var enemy_pos = PlayerController.get_nearest_enemy().global_position
		facing_right = enemy_pos.x >= global_position.x
	elif dir.x != 0:  # Only update facing if moving horizontally
		facing_right = dir.x > 0

	if dir != Vector2.ZERO:
		var anim_speed = 1.0 + (PlayerController.movement_speed - 200.0) * 0.01
		anim_speed = clamp(anim_speed, 2.0, 6.0)
		animation_player.speed_scale = anim_speed

		if facing_right:
			animation_player.play("walk_right")
		else:
			animation_player.play("walk_left")
	else:
		animation_player.speed_scale = 1.0
		if facing_right:
			animation_player.play("idle_right")
		else:
			animation_player.play("idle_left")

	var input_velocity = Vector2.ZERO
	if dir != Vector2.ZERO:
		input_velocity = dir.normalized() * speed
		#dir = dir.normalized()
		#var motion := dir * speed * delta
		#var collision := move_and_collide(motion)
#
		#if collision:
			#var normal := collision.get_normal()
			#var move_dir := motion.normalized()
			#var angle = abs(move_dir.angle_to(normal))
#
			#if angle >= PI / 4.0:
				#move_and_collide(motion.slide(normal))
	var final_velocity = input_velocity + external_velocity
	velocity = final_velocity
	move_and_slide()
	external_velocity = external_velocity.move_toward(Vector2.ZERO, external_drag * delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = PlayerController.movement_speed
	face_enemy()
	
	if player.attacking == false and not dead:
		arms.play("idle")
	if player.attacking == true and not dead:
		arms.play("default")
	
	if PlayerController.clicks_per_second >= 15:
		arms.set_speed_scale(2.0)
	elif PlayerController.clicks_per_second >= 10:
		arms.set_speed_scale(1.4)

	var percentage = float(player.current_hp) / player.max_hp
	if player.current_hp <= 0:
		dead = true
		PlayerController.dead = true
		arms.play("die")
		animation_player.play("die")
		head.texture = HEAD_DEAD
		body.texture = BODY_DEAD
		eyes.play("dead")
		mouth.play("sad")
	elif percentage <= 0.10:
		head.texture = HEAD_DIRE
		body.texture = BODY_DIRE
		if not damage_taken and not blinking:
			eyes.play("weak")
			mouth.play("sad")
	elif percentage < 0.30:
			head.texture = HEAD_PAIN
			body.texture = BODY_NORMAL
			if not damage_taken and not blinking:
				eyes.play("sad")
				mouth.play("sad")
	elif percentage < 0.60:
		body.texture = BODY_NORMAL
		head.texture = HEAD_NORMAL
		if not damage_taken and not blinking:
			eyes.play("smile")
			mouth.play("normal")
	elif percentage >= 0.60:
		body.texture = BODY_NORMAL
		head.texture = HEAD
		if not damage_taken and not blinking:
			eyes.play("smile")
			mouth.play("smile")

func take_damage(damage, pen, trigger_iframes: bool = true, params = []):
	PlayerController.take_damage(damage, pen, trigger_iframes, params)
	
func is_alive():
	return true

func reset_player_model():
	shadow.visible = true
	dead = false
	arms.play("default")
	animation_player.play("idle")

func face_enemy():
	if not PlayerController.get_nearest_enemy():
		return
	var enemy_pos = PlayerController.get_nearest_enemy().global_position
	if enemy_pos.x < global_position.x:
		return false
	else:
		return true

func get_sling_position():
	return slingshot_origin.global_position

func _on_blink_timeout() -> void:
	eyes.play("blink")
	blinking = true
	await get_tree().create_timer(0.2).timeout
	blinking = false
	if randi_range(0, 1) == 1:
		await get_tree().create_timer(0.2).timeout
		eyes.play("blink")
		blinking = true
		await get_tree().create_timer(0.2).timeout
		blinking = false
	blink_timer.start(randf_range(1.0, 6.0))

func _on_damage_taken():
	iframes.start(PlayerController.iframes)
	if PlayerController.invincible:
		modulate_player.play("damage")
	eyes.play("hurt")
	mouth.play("hurt")
	damage_taken = true

func _on_iframes_timeout() -> void:
	damage_taken = false
	modulate_player.play("default")

func apply_knockback(dir: Vector2, strength: float = 500.0, trigger_knockback_cd: bool = true):
	if knockback_cooldown_active:
		return
	external_velocity += dir.normalized() * strength
	if trigger_knockback_cd:
		apply_knockback_cooldown()

func apply_knockback_cooldown():
	knockback_cooldown_active = true
	await get_tree().create_timer(0.2).timeout
	knockback_cooldown_active = false
