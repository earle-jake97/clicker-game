extends EnemyStatusEffect
class_name BleedEffect

@export var stack_count: int = 1
@export var damage_per_stack: float = 1.0

const BLEED_ICON = preload("uid://csxfl4ik5outu")

var tick_timer: float = 0.0

func get_effect_id() -> String:
	return "bleed"

func is_negative_effect() -> bool:
	return true

func add_stack(amount: int = 1, new_damage_per_stack: float = -1.0) -> void:
	stack_count += amount

	if new_damage_per_stack >= 0.0:
		damage_per_stack = max(damage_per_stack, new_damage_per_stack)

	if enemy != null:
		enemy.refresh_enemy_ui()

func on_reapplied(new_effect: EnemyStatusEffect) -> void:
	super.on_reapplied(new_effect)

	if new_effect is BleedEffect:
		stack_count += new_effect.stack_count
		damage_per_stack = max(damage_per_stack, new_effect.damage_per_stack)

	if enemy != null:
		enemy.refresh_enemy_ui()

func on_enemy_process(delta: float) -> void:
	super.on_enemy_process(delta)

	if enemy == null or enemy.dead:
		return

	tick_timer += delta

	while tick_timer >= 1.0:
		tick_timer -= 1.0
		_apply_bleed_tick()
		
func get_stack_count() -> int:
	return stack_count

func get_icon() -> Texture2D:
	return BLEED_ICON

func _apply_bleed_tick() -> void:
	if enemy == null or enemy.dead:
		return

	var damage := stack_count * damage_per_stack
	if damage <= 0.0:
		return

	enemy.take_damage(damage, DamageBatcher.DamageType.NORMAL, "bleed")
