extends Node2D

@onready var label: Label = $Label
var crit = false
var finished_callback: Callable = Callable()
var original_z = 3000
const LIFETIME := 5.0 # seconds before force despawn

func _ready() -> void:
	z_index = original_z
	start_despawn_timer() # Ensure cleanup happens eventually

func show_number(amount: int, color: Color = Color.WHITE, update_only: bool = false):
	if amount > 0:
		var amount_str = format_large_number(amount)
		label.text = amount_str

		var scaled_size = clamp(8 + log(amount) * 3.5, 8, 64)
		label.add_theme_font_size_override("font_size", int(scaled_size))

		z_index = original_z - int(scaled_size)
	else:
		label.text = ""
	label.modulate = color

	if not update_only:
		animate()

func animate():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.5)

func animate_and_destroy():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.5)

	tween.tween_callback(func():
		if finished_callback.is_valid():
			finished_callback.call()
		queue_free()
	).set_delay(0.6)

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

func start_despawn_timer():
	await get_tree().create_timer(LIFETIME).timeout
	if is_inside_tree(): # still valid
		queue_free()
