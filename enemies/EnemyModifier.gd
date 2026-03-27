extends Node
class_name EnemyModifier

var enemy: BaseEnemy = null

func setup(target_enemy: BaseEnemy) -> void:
	enemy = target_enemy

func on_added() -> void:
	pass

func on_removed() -> void:
	pass

func on_enemy_spawned() -> void:
	pass

func on_enemy_process(_delta: float) -> void:
	pass

func on_enemy_death_started() -> void:
	pass

func apply_stats(stats: Dictionary) -> Dictionary:
	return stats

func recalculate_enemy_stats() -> void:
	if enemy:
		enemy.recalculate_stats()
