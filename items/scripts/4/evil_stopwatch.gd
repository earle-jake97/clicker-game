extends BaseItem
const item_name = "Evil Stopwatch"
const item_description = "Every item that activates on a timer will activate an additional time"
const item_icon = preload("res://items/icons/evil_stopwatch.png")
const tags = ["timer_procs"]
const rarity = 4
var file_name = "res://items/scripts/4/evil_stopwatch.gd"
var occurrences = 1


func _process(delta: float) -> void:
	pass
