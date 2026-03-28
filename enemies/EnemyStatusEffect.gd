extends Node
class_name EnemyStatusEffect

var enemy: BaseEnemy = null
var duration: float = 0.0
var elapsed: float = 0.0
var source_id: String = ""

func setup(target_enemy: BaseEnemy, effect_duration: float) -> void:
	enemy = target_enemy
	duration = effect_duration
	elapsed = 0.0

func on_added() -> void:
	pass

func on_removed() -> void:
	pass

func on_enemy_process(delta: float) -> void:
	elapsed += delta

func on_enemy_died() -> void:
	pass

func apply_stats(stats: Dictionary) -> Dictionary:
	return stats

func get_move_slow_amount() -> float:
	return 0.0

func get_attack_speed_slow_amount() -> float:
	return 0.0

func get_effect_id() -> String:
	return ""

func get_effect_display_name() -> String:
	return get_effect_id()

func get_remaining_duration() -> float:
	return max(duration - elapsed, 0.0)

func is_expired() -> bool:
	return elapsed >= duration

func is_negative_effect() -> bool:
	return true

func should_merge_with(other: EnemyStatusEffect) -> bool:
	if other == null:
		return false

	if source_id.is_empty() or other.source_id.is_empty():
		return false

	return get_script() == other.get_script() and source_id == other.source_id

func on_reapplied(new_effect: EnemyStatusEffect) -> void:
	if new_effect == null:
		return

	duration = max(duration, elapsed + new_effect.duration)

func get_effect_icon() -> Texture2D:
	return null

func get_stack_count() -> int:
	return 1
