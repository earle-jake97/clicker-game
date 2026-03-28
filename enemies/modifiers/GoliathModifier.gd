extends EnemyModifier
class_name GoliathModifier

const GOLIATH_ICON = preload("uid://dsvhaayhexc4x")

@export var scale_multiplier: float = 1.1
@export var damage_multiplier: float = 2.0
@export var move_speed_multiplier: float = 0.8

func apply_stats(stats: Dictionary) -> Dictionary:
	stats["visual_scale"] *= scale_multiplier
	stats["damage"] *= damage_multiplier
	stats["move_speed"] *= move_speed_multiplier
	stats["walk_animation_speed"] *= move_speed_multiplier
	return stats

func get_modifier_id() -> String:
	return "goliath"

func get_modifier_icon() -> Texture2D:
	return GOLIATH_ICON
