extends EnemyStatusEffect
class_name AttackSpeedSlowEffect

@export var slow_percent: float = 0.30

func apply_stats(stats: Dictionary) -> Dictionary:
	return stats

func get_attack_speed_slow_amount() -> float:
	return slow_percent

func get_effect_id() -> String:
	return "attack_speed_slow"

func on_reapplied(new_effect: EnemyStatusEffect) -> void:
	super.on_reapplied(new_effect)

	if new_effect is AttackSpeedSlowEffect:
		slow_percent = max(slow_percent, new_effect.slow_percent)
