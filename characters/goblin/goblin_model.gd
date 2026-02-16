extends CharacterBody2D
var dead = false
@onready var head: Sprite2D = $sprite/body/head
var player = PlayerController
const HEAD = preload("res://sprites/test_player/head.png")
const HEAD_NORMAL = preload("res://sprites/test_player/head_normal.png")
const HEAD_PAIN = preload("res://sprites/test_player/head_pain.png")
const HEAD_DIRE = preload("res://sprites/test_player/head_dire.png")
const HEAD_DEAD = preload("res://sprites/test_player/head_dead.png")
const BODY_DIRE = preload("res://sprites/test_player/body_dire.png")
const BODY_DEAD = preload("res://sprites/test_player/body_dead.png")
const BODY_NORMAL = preload("res://sprites/test_player/body.png")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arms: AnimatedSprite2D = $sprite/body/arms
@onready var body: Sprite2D = $sprite/body
@onready var shadow: Sprite2D = $shadow
@onready var slingshot_origin: Marker2D = $sprite/body/arms/slingshot_origin

@export var base_speed := 180.0
var speed := base_speed
var facing_right = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerController.set_player(self)
	animation_player.animation_set_next("move_up", "idle")
	animation_player.animation_set_next("move_down", "idle")
	animation_player.animation_set_next("die", "dead")
	
	
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

	if dir != Vector2.ZERO:
		dir = dir.normalized()
		var motion := dir * speed * delta
		var collision := move_and_collide(motion)

		if collision:
			var normal := collision.get_normal()
			var move_dir := motion.normalized()
			var angle = abs(move_dir.angle_to(normal))

			if angle >= PI / 4.0:
				move_and_collide(motion.slide(normal))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
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
		shadow.visible = false
		arms.play("die")
		animation_player.play("die")
		head.texture = HEAD_DEAD
		body.texture = BODY_DEAD
	elif percentage <= 0.10:
		head.texture = HEAD_DIRE
		body.texture = BODY_DIRE
		body.texture = BODY_NORMAL
	elif percentage < 0.30:
			head.texture = HEAD_PAIN
			body.texture = BODY_NORMAL
			
	elif percentage < 0.60:
		body.texture = BODY_NORMAL
		head.texture = HEAD_NORMAL
	elif percentage >= 0.60:
		body.texture = BODY_NORMAL
		head.texture = HEAD

func take_damage(damage, pen):
	PlayerController.take_damage(damage, pen)
	
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
