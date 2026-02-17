extends CanvasLayer
@onready var pause_menu: CanvasLayer = $"."
@onready var item_grid: GridContainer = $ItemGrid
const ITEM_DISPLAY = preload("res://systems/item_display.tscn")
@onready var dmg_label: Label = $dmg_label
@onready var as_label: Label = $as_label
@onready var crit_rate_label: Label = $crit_rate_label
@onready var crit_dmg_label: Label = $crit_dmg_label
@onready var armor_label: Label = $armor_label
@onready var luck_label: Label = $luck_label
@onready var color_rect_2: ColorRect = $ColorRect2
@onready var yes_button: Button = $ColorRect2/Sprite2D/yes_button
@onready var no_button: Button = $ColorRect2/Sprite2D/no_button
@onready var restart_button: TextureButton = $RestartButton
@onready var ms_label: Label = $ms_label



var paused = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused:
		pause_menu.visible = true
	else:
		pause_menu.visible = false
	if Input.is_action_just_pressed("Pause") and not GameState.on_start_screen:
		if color_rect_2.visible:
			color_rect_2.visible = false
		elif paused:
			Tooltip.hide_tooltip()
			get_tree().paused = false
			paused = false
		else:
			get_tree().paused = true
			paused = true
			

func update_inventory_display():
	for child in item_grid.get_children():
		item_grid.remove_child(child)
		child.queue_free()
	
	var counted_items = {}
	
	for item in PlayerController.inventory:
		if item.item_name in counted_items:
			counted_items[item.item_name]["count"] += 1
		else:
			counted_items[item.item_name] = {
				"item": item,
				"count": 1
			}
	for entry in counted_items.values():
		var item_display = ITEM_DISPLAY.instantiate()
		item_grid.add_child(item_display)
		item_display.setup(entry["item"], entry["count"])

func update_labels():
	var dmg = (PlayerController.damage + PlayerController.additional_dmg) * (PlayerController.mult_dmg + 1)
	dmg_label.text = str(format_large_number(dmg))
	
	var attack_speed = PlayerController.clicks_per_second
	as_label.text = str(format_large_number(attack_speed)) + "/sec"
	
	var crit_rate = PlayerController.crit_chance
	crit_rate_label.text = str(min((crit_rate * 100), 100)) + "%"
	
	var crit_dmg = PlayerController.crit_damage
	crit_dmg_label.text = str(crit_dmg * 100) + "%"
	
	armor_label.text = str(PlayerController.total_armor)
	
	luck_label.text = str(PlayerController.luck)
	
	ms_label.text = str(PlayerController.movement_speed)

func format_large_number(number: int) -> String:
	var suffixes = ["", "k", "m", "b", "t", "q", "Q", "s", "S", "o", "n", "d"]
	var magnitude = 0
	var num = float(number)

	while num >= 1000.0 and magnitude < suffixes.size() - 1:
		num /= 1000.0
		magnitude += 1

	var formatted = "%.2f" % num
	if formatted.ends_with(".00"):
		formatted = formatted.left(formatted.length() - 3)
	elif formatted.ends_with("0"):
		formatted = formatted.left(formatted.length() - 1)

	return formatted + suffixes[magnitude]


func _on_restart_button_pressed() -> void:
	color_rect_2.visible = true



func _on_yes_button_pressed() -> void:
	color_rect_2.visible = false
	Tooltip.hide_tooltip()
	paused = false
	get_tree().paused = false
	PlayerController.reset_to_defaults()
	


func _on_no_button_pressed() -> void:
	Tooltip.hide_tooltip()
	color_rect_2.visible = false
