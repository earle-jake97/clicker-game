extends Node

class_name DamageBatcher

const number_scene = preload("res://scenes/damage_number.tscn")
enum DamageType { NORMAL, CRIT, BLEED, LIGHTNING, FIRE }

# Each entry holds: total_damage, crit_occurred, timer, number_instance
var batches: Dictionary = {}

func _ready():
	for type in DamageType.values():
		var timer := Timer.new()
		timer.one_shot = true
		timer.wait_time = 1.25
		timer.timeout.connect(_on_timer_timeout.bind(type))
		add_child(timer)

		batches[type] = {
			"total_damage": 0,
			"crit_occurred": false,
			"number_instance": null,
			"timer": timer
		}

func add_damage(amount: int, type: int = DamageType.NORMAL):
	var batch = batches[type]
	batch.total_damage += amount
	if type == DamageType.CRIT:
		batch.crit_occurred = true

	var color = get_color_for_type(type)

	if batch.number_instance == null or not is_instance_valid(batch.number_instance) or not batch.number_instance.is_inside_tree():
		var instance = number_scene.instantiate()
		instance.crit = batch.crit_occurred
		instance.finished_callback = Callable(self, "_on_number_finished").bind(type)
		instance.global_position = get_parent().global_position + Vector2(randf_range(-10, 10), -20) + get_type_offset(type)
		get_tree().root.add_child(instance)
		instance.global_position = get_parent().global_position + Vector2(randf_range(-10, 10), -20)
		instance.show_number(batch.total_damage, color)
		batch.number_instance = instance
	else:
		batch.number_instance.crit = batch.crit_occurred
		batch.number_instance.show_number(batch.total_damage, color, true)

	# Start or restart timer
	if batch.timer.is_stopped():
		batch.timer.start()

func _on_timer_timeout(type: int):
	var batch = batches[type]
	if is_instance_valid(batch.number_instance):
		batch.number_instance.animate_and_destroy()
		batch.number_instance = null
	batch.total_damage = 0
	batch.crit_occurred = false

func _on_number_finished(type: int):
	var batch = batches[type]
	batch.number_instance = null
	batch.total_damage = 0
	batch.crit_occurred = false

func get_color_for_type(type: int) -> Color:
	match type:
		DamageType.BLEED:
			return Color(0.6, 0.1, 0.2)
		DamageType.CRIT:
			return Color(1.0, 0.9, 0.3)
		DamageType.LIGHTNING:
			return Color.CADET_BLUE
		DamageType.FIRE:
			return Color.ORANGE
		_:
			return Color(1, 1, 1)

func get_type_offset(type: int) -> Vector2:
	match type:
		DamageType.NORMAL:
			return Vector2(-40, 0)
		DamageType.CRIT:
			return Vector2(0, -20)
		DamageType.BLEED:
			return Vector2(40, 20)
		DamageType.LIGHTNING:
			return Vector2(-10, 20)
		_:
			return Vector2(0, 0)
