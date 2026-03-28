extends EnemyModifier
class_name DecayModifier

@export var tick_rate: float = 0.5
@export var percent_max_health_per_tick: float = 0.05
@export var suppress_drops_while_active: bool = true

var tick_timer: float = 0.0

func on_added() -> void:
	if enemy == null:
		return

	if suppress_drops_while_active:
		enemy.suppress_random_drops = true

func on_removed() -> void:
	if enemy == null:
		return

	if suppress_drops_while_active:
		enemy.suppress_random_drops = false

func on_enemy_process(delta: float) -> void:
	if enemy == null:
		return

	if enemy.dead or enemy.spawning:
		return

	tick_timer += delta
	if tick_timer < tick_rate:
		return

	tick_timer = 0.0

	var decay_damage = enemy.max_health * percent_max_health_per_tick
	enemy.take_damage(decay_damage, DamageBatcher.DamageType.NORMAL, "decay")

func get_modifier_id() -> String:
	return "decay"
