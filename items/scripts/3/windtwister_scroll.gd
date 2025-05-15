extends BaseItem

var tags = ["wind", "knockback"]
var rarity = 2
const item_name = "Windtwister Scroll"
const item_description = "Every 11 seconds, you place down a gust of wind in your lane. This will blow away small enemies."
const item_icon = preload("res://items/icons/windtwister_scroll.png")
var file_name = "res://items/scripts/2/windtwister_scroll.gd"
const BLOW_BOX = preload("res://items/misc/blow_box.tscn")
var elapsed_time = 0.0
const TIMER_DURATION = 11.0


func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= TIMER_DURATION and get_tree().get_nodes_in_group("enemy").size() > 0:
		elapsed_time -= TIMER_DURATION 
		timed_blow()
	
	# Determine push strength
	

func timed_blow():
	var strength = 0
	for item in player.inventory:
		if "Windtwister Scroll" in item.item_name:
			strength += 0.5
	var blow_scene = BLOW_BOX.instantiate()
	blow_scene.strength = strength
	blow_scene.global_position = TestPlayer.global_position
	add_child(blow_scene)
