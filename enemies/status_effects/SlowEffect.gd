extends EnemyStatusEffect
class_name SlowEffect

@export var slow_percent: float = 0.30

func apply_stats(stats: Dictionary) -> Dictionary:
	return stats
const SLOW_ICON = preload("uid://he0g130e546l")

func get_move_slow_amount() -> float:
	return slow_percent

func get_effect_id() -> String:
	return "slow"

func on_reapplied(new_effect: EnemyStatusEffect) -> void:
	super.on_reapplied(new_effect)

	if new_effect is SlowEffect:
		slow_percent = max(slow_percent, new_effect.slow_percent)

func get_icon() -> Texture2D:
	return SLOW_ICON
