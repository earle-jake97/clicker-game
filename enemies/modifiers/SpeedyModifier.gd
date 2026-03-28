extends EnemyModifier
class_name SpeedyModifier

const SPEEDY_ICON = preload("uid://bf2fg60pyva2e")


@export var speed_multiplier: float = 1.5

func apply_stats(stats: Dictionary) -> Dictionary:
	stats["move_speed"] *= speed_multiplier
	stats["walk_animation_speed"] *= speed_multiplier
	stats["attack_animation_speed"] *= speed_multiplier
	return stats

func get_modifier_id() -> String:
	return "speedy"

func get_modifier_icon() -> Texture2D:
	return SPEEDY_ICON
