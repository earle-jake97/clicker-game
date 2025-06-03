extends BaseItem

var elapsed_time := 0.0
const TIMER_DURATION := 5.0
var amount_of_times_to_click = 1
const item_name = "Super Stopwatch"
const item_description = "Every 5s you attack everything on screen automatically."
var tags = ["timer"]
var rarity = 4
var item_icon = preload("res://items/icons/super_stopwatch.png")
var file_name = "res://items/scripts/4/super_stopwatch.gd"

func _ready() -> void:
	connect("reset", Callable(self, "queue_free"))

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= TIMER_DURATION:
		elapsed_time -= TIMER_DURATION 
		timed_click()

func timed_click():
	player.attack_all_enemies() # Always attack once
	var timer_procs = 0
	for item in player.inventory:
		var tags = item.tags
		if "timer_procs" in tags:
			timer_procs += item.occurrences
	for x in range(timer_procs):
		player.attack_all_enemies() # Attack once per item
