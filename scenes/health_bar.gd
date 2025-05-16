extends Control
const HEART_ICON_DIRE = preload("res://systems/heart_icon_dire.png")
const HEART_ICON_HEALTHY = preload("res://systems/heart_icon_healthy.png")
const HEART_ICON_LOW = preload("res://systems/heart_icon_low.png")
const HEART_ICON_MEDIUM = preload("res://systems/heart_icon_medium.png")
const HEART_ICON_DEAD = preload("res://systems/heart_icon_dead.png")
@onready var hp_sprite: Sprite2D = $HP_Sprite
@onready var hp: Label = $HP
var player = PlayerController
@onready var cash: Label = $Cash
const HEART_CASH_DEAD = preload("res://systems/heart_cash_dead.png")
@onready var cash_sprite: Sprite2D = $Cash_Sprite
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer
@onready var label: Label = $Label
@onready var temp: AnimationPlayer = $Label/temp
@onready var endless_sprite: Sprite2D = $endless_sprite
@onready var room_count: Label = $endless_sprite/room_count
@onready var button: TextureButton = $Button
var fast_forward = false

var dead = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	room_count.text = str(GameState.endless_counter)
	var percentage = float(player.current_hp) / player.max_hp
	if percentage <= 0.0 and not dead:
		dead = true
		temp.play("text")
		animation_player.play("death")
	switch_sprite(percentage)
	hp.text = str(format_large_number(player.current_hp)) + "/" + str(format_large_number(player.max_hp))
	cash.text = format_large_number(player.cash)
	

func switch_sprite(percent):
	if percent <= 0.0:
		hp_sprite.texture = HEART_ICON_DEAD
		cash_sprite.texture = HEART_CASH_DEAD
	elif percent <= 0.1:
		hp_sprite.texture = HEART_ICON_DIRE
	elif percent <= 0.3:
		hp_sprite.texture = HEART_ICON_LOW
	elif percent <= 0.6:
		hp_sprite.texture = HEART_ICON_MEDIUM
	else:
		hp_sprite.texture = HEART_ICON_HEALTHY

func format_large_number(number: int) -> String:
	var suffixes = [
		"", "k", "m", "b", "t", "q", "Q", "s", "S", "o", "n", "d"
	]  # "", thousand, million, billion, trillion, etc. up to decillion
	var magnitude = 0
	var num = float(number)

	while num >= 1000.0 and magnitude < suffixes.size() - 1:
		num /= 1000.0
		magnitude += 1

	# Format to 2 decimal places max, removing trailing zeros
	var formatted = "%.2f" % num
	if formatted.ends_with(".00"):
		formatted = formatted.left(formatted.length() - 3)
	elif formatted.ends_with("0"):
		formatted = formatted.left(formatted.length() - 1)

	return formatted + suffixes[magnitude]


func _on_button_pressed() -> void:
	fast_forward = not fast_forward
	if fast_forward:
			Engine.time_scale = 5.0
	else:
		Engine.time_scale = 1.0
