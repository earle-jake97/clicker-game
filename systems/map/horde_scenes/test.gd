extends Node2D
const SuperStopwatch = preload("res://items/scripts/4/super_stopwatch.gd")
#const NumberFanatic = preload("res://items/scripts/3/number_fanatic.gd")
const synergy = preload("res://items/scripts/4/evil_stopwatch.gd")
@onready var player = PlayerController  # assuming this is a reference to the actual player node
const Thunderbolt = preload("res://items/scripts/3/thunderbolt.gd")
const spring = preload("res://items/scripts/3/spring.gd")
const ghost = preload("res://items/scripts/3/missing_soul.gd")
@onready var background: Sprite2D = $background
const BowlingBall = preload("res://items/scripts/2/bowling_ball.gd")
const _1 = preload("res://backgrounds/1.png")
const _1_BRIGHT = preload("res://backgrounds/1_bright.png")
const _1_DAY = preload("res://backgrounds/1_day.png")
const IceCube = preload("res://items/scripts/2/ice_cube.gd")
const Oil = preload("res://items/scripts/2/oil.gd")
const Awp = preload("res://items/scripts/2/awp.gd")
const WindtwisterScroll = preload("res://items/scripts/2/windtwister_scroll.gd")
func _ready():

	#var item_instance = WindtwisterScroll.new()
	#player.add_item(item_instance)
#
	## Optional: If it needs to run _process or emit signals
	#if not item_instance.is_inside_tree():
		#player.add_child(item_instance)
	##
	#player.add_item(item_instance)
	#player.add_item(item_instance)
	#player.add_item(item_instance)
	

	# Optional: If it needs to run _process or emit signals
	#if not item_instance.is_inside_tree():
		#player.add_child(item_instance)
	pass

func _process(delta: float) -> void:
	if PlayerController.difficulty >= 6:
		background.texture = _1
	elif PlayerController.difficulty >= 3:
		background.texture = _1_DAY
	else:
		background.texture = _1_BRIGHT
