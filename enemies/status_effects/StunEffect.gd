extends EnemyStatusEffect
class_name StunEffect

const STUN_ICON = preload("uid://bei6c6r5pskm6")

func on_added() -> void:
	if enemy == null:
		return

	enemy.set_state(enemy.EnemyState.STUNNED)

func on_enemy_process(delta: float) -> void:
	super.on_enemy_process(delta)

	if enemy == null:
		return

	if enemy.dead:
		return

	if enemy.current_state != enemy.EnemyState.STUNNED:
		enemy.set_state(enemy.EnemyState.STUNNED)

func on_removed() -> void:
	if enemy == null:
		return

	if enemy.dead:
		return

	if enemy.current_state == enemy.EnemyState.STUNNED:
		enemy.set_state(enemy.EnemyState.IDLE)

func get_effect_id() -> String:
	return "stun"
	
func get_icon() -> Texture2D:
	return STUN_ICON
