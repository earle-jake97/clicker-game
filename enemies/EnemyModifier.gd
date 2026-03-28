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

func on_enemy_died() -> void:
	pass

func apply_stats(stats: Dictionary) -> Dictionary:
	return stats

func get_modifier_id() -> String:
	return ""

func get_modifier_icon() -> Texture2D:
	return null
