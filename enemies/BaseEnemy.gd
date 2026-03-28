extends Node2D
class_name BaseEnemy

signal died
signal spawned
signal state_changed(old_state, new_state)
signal attack_started
signal attack_hit
signal attack_finished

enum EnemyState {
	SPAWNING,
	IDLE,
	MOVING,
	ATTACKING,
	STUNNED,
	SPECIAL,
	DEAD
}

var player = PlayerController
var player_model

@export var damage_number_scene: PackedScene = preload("res://scenes/damage_number.tscn")
@export var value_min: int = 1
@export var value_max: int = 1

@onready var health_bar_anchor: Marker2D = $container/HealthBarAnchor
@onready var health_bar: TextureProgressBar = $ProgressBar
@onready var damage_batcher: DamageBatcher = $Node2D/batcher
@onready var shadow: Sprite2D = $container/shadow
@onready var animation_player: AnimationPlayer = $container/AnimationPlayer
@onready var container: Node2D = $container
@onready var sprite: Node2D = $container/sprite
@onready var nav2d: NavigationAgent2D = $NavigationAgent2D
@onready var area_2d: Area2D = $container/Area2D

var variant = EnemyManager.variant.NORMAL
const MONEY_DROP = preload("uid://c0vl7qr3w4dfp")

@export var base_max_health: float = 10.0
@export var base_move_speed: float = 0.0
@export var base_damage: int = 0
@export var base_armor_penetration: int = 0
@export var base_attack_cooldown: float = 1.0
@export var base_attack_animation_speed: float = 1.0
@export var base_knockback_strength: float = 0.0
@export var base_walk_animation_speed: float = 1.0
@export var base_visual_scale: float = 1.0

var max_health: float = 10.0
var health: float = 10.0
var move_speed: float = 0.0
var damage: int = 0
var armor_penetration: int = 0
var attack_cooldown: float = 1.0
var attack_animation_speed: float = 1.0
var walk_animation_speed: float = 1.0
var knockback_strength: float = 0.0
var visual_scale: float = 1.0

var current_state: EnemyState = EnemyState.SPAWNING
var previous_state: EnemyState = EnemyState.SPAWNING

var independent_look := false
var touching_entity: Node = null
var touching_player := false
var bleed_stacks := 0
var dead := false
var paid_out := false
var value := 0
var push_strength := 0.0
var pushback_length := 2.0
var pushback_timer := 0.0
var is_pushed := false
var target: Node = null
var pitch_scale = randf_range(0.9, 1.3)
var trigger_knockback := true
var can_move := true
var item_rolled := false
var active := false
var spawning := true
var invulnerable := false
var targetable := true
var suppress_random_drops := false

var modifiers: Array[EnemyModifier] = []
var status_effects: Array[EnemyStatusEffect] = []

var modifier_container: Node = null
var status_effect_container: Node = null

var path_update_timer := 0.0
var update_interval := 0.1
var catchup_timer := 0.0
var catchup_interval := 0.5
var attack_cooldown_timer := 0.0

func _ready() -> void:
	await get_tree().process_frame

	player_model = PlayerController.get_player_body()
	target = player_model

	_ensure_effect_containers()

	if EnemyManager.get_all_enemies().size() >= 50:
		shadow.visible = false

	EnemyManager.optimize.connect(_optimize)
	EnemyManager.kill_all.connect(_die_from_manager)
	EnemyManager.register(self)

	value = randi_range(value_min, value_max)

	configure_enemy()
	recalculate_stats()

	health = max_health

	if health_bar:
		health_bar.visible = false
		health_bar.max_value = max_health
		health_bar.value = health

	if is_instance_valid(player_model):
		nav2d.target_position = player_model.global_position

	if animation_player.has_animation("spawn"):
		animation_player.play("spawn")
		await animation_player.animation_finished

	spawning = false
	set_state(EnemyState.IDLE)
	spawned.emit()

	for modifier in modifiers:
		if is_instance_valid(modifier):
			modifier.on_enemy_spawned()

	await get_tree().physics_frame
	if is_instance_valid(player_model):
		nav2d.target_position = player_model.global_position

	refresh_enemy_ui()

func _physics_process(delta: float) -> void:
	if dead:
		return

	update_health_bar_position()

	update_common_timers(delta)
	check_touch()
	update_target()
	process_status_effects(delta)
	process_modifiers(delta)

	if health < max_health and health_bar:
		health_bar.visible = true

	enemy_process(delta)
	process_current_state(delta)
	health_below_zero()

func configure_enemy() -> void:
	pass

func enemy_process(_delta: float) -> void:
	pass

func should_enter_moving_state() -> bool:
	return false

func should_start_attack() -> bool:
	return false

func enter_state(_new_state: EnemyState) -> void:
	pass

func exit_state(_old_state: EnemyState) -> void:
	pass

func state_idle(_delta: float) -> void:
	if should_enter_moving_state():
		set_state(EnemyState.MOVING)
	elif should_start_attack():
		set_state(EnemyState.ATTACKING)

func state_moving(_delta: float) -> void:
	if should_start_attack():
		set_state(EnemyState.ATTACKING)

func state_attacking(_delta: float) -> void:
	pass

func state_stunned(_delta: float) -> void:
	pass

func state_special(_delta: float) -> void:
	pass

func state_dead(_delta: float) -> void:
	pass

func set_state(new_state: EnemyState) -> void:
	if dead and new_state != EnemyState.DEAD:
		return

	if current_state == new_state:
		return

	var old_state = current_state
	exit_state(old_state)

	previous_state = old_state
	current_state = new_state

	enter_state(new_state)
	state_changed.emit(old_state, new_state)

func process_current_state(delta: float) -> void:
	match current_state:
		EnemyState.SPAWNING:
			pass
		EnemyState.IDLE:
			state_idle(delta)
		EnemyState.MOVING:
			state_moving(delta)
		EnemyState.ATTACKING:
			state_attacking(delta)
		EnemyState.STUNNED:
			state_stunned(delta)
		EnemyState.SPECIAL:
			state_special(delta)
		EnemyState.DEAD:
			state_dead(delta)

func can_act() -> bool:
	return not dead and not spawning and current_state != EnemyState.STUNNED

func can_attack() -> bool:
	return can_act() and attack_cooldown_timer <= 0.0

func can_be_targeted() -> bool:
	return targetable and not dead

func can_receive_status_effect(effect: EnemyStatusEffect) -> bool:
	if dead or effect == null:
		return false

	return true

func update_common_timers(delta: float) -> void:
	path_update_timer += delta
	catchup_timer += delta

	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	if catchup_timer >= catchup_interval:
		catch_up()

func check_touch() -> void:
	if touching_entity and not is_instance_valid(touching_entity):
		touching_entity = null
		touching_player = false

func update_target() -> void:
	var best_target: Node = player_model
	var best_distance := INF

	for entity in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(entity):
			continue

		if entity.has_method("is_alive") and not entity.is_alive():
			continue

		if entity.has_method("can_be_targeted") and not entity.can_be_targeted():
			continue

		var distance = global_position.distance_to(entity.global_position)
		if distance < best_distance:
			best_distance = distance
			best_target = entity

	target = best_target
	look_at_target()

func look_at_target() -> void:
	if dead or independent_look or not is_instance_valid(target):
		return

	if global_position.x > target.global_position.x:
		container.scale.x = abs(container.scale.x)
	else:
		container.scale.x = -abs(container.scale.x)

func build_base_stats() -> Dictionary:
	return {
		"max_health": base_max_health,
		"move_speed": base_move_speed,
		"damage": base_damage,
		"armor_penetration": base_armor_penetration,
		"attack_cooldown": base_attack_cooldown,
		"attack_animation_speed": base_attack_animation_speed,
		"walk_animation_speed": base_walk_animation_speed,
		"knockback_strength": base_knockback_strength,
		"visual_scale": base_visual_scale,
	}

func combine_slow_multipliers(amounts: Array[float], minimum_multiplier: float = 0.15) -> float:
	var multiplier := 1.0

	for amount in amounts:
		var clamped_amount := clampf(amount, 0.0, 0.95)
		multiplier *= (1.0 - clamped_amount)

	return clampf(multiplier, minimum_multiplier, 1.0)

func _get_move_slow_multiplier() -> float:
	var move_slow_amounts: Array[float] = []

	for effect in status_effects:
		if not is_instance_valid(effect):
			continue

		var slow_amount := effect.get_move_slow_amount()
		if slow_amount > 0.0:
			move_slow_amounts.append(slow_amount)

	return combine_slow_multipliers(move_slow_amounts, 0.15)

func _get_attack_speed_slow_multiplier() -> float:
	var attack_slow_amounts: Array[float] = []

	for effect in status_effects:
		if not is_instance_valid(effect):
			continue

		var slow_amount := effect.get_attack_speed_slow_amount()
		if slow_amount > 0.0:
			attack_slow_amounts.append(slow_amount)

	return combine_slow_multipliers(attack_slow_amounts, 0.25)

func recalculate_stats() -> void:
	var stats = build_base_stats()

	for modifier in modifiers:
		if is_instance_valid(modifier):
			stats = modifier.apply_stats(stats)

	for effect in status_effects:
		if is_instance_valid(effect):
			stats = effect.apply_stats(stats)

	var move_slow_multiplier := _get_move_slow_multiplier()
	var attack_speed_slow_multiplier := _get_attack_speed_slow_multiplier()

	stats["move_speed"] *= move_slow_multiplier
	stats["walk_animation_speed"] *= move_slow_multiplier
	stats["attack_animation_speed"] *= attack_speed_slow_multiplier

	max_health = stats["max_health"]
	move_speed = stats["move_speed"]
	damage = stats["damage"]
	armor_penetration = stats["armor_penetration"]
	attack_cooldown = stats["attack_cooldown"]
	attack_animation_speed = stats["attack_animation_speed"]
	walk_animation_speed = stats["walk_animation_speed"]
	knockback_strength = stats["knockback_strength"]
	visual_scale = stats["visual_scale"]

	health = clamp(health, 0.0, max_health)

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

	apply_visual_scale()
	update_current_animation_speed()

func _ensure_effect_containers() -> void:
	modifier_container = get_node_or_null("Modifiers")
	if modifier_container == null:
		modifier_container = Node.new()
		modifier_container.name = "Modifiers"
		add_child(modifier_container)

	status_effect_container = get_node_or_null("StatusEffects")
	if status_effect_container == null:
		status_effect_container = Node.new()
		status_effect_container.name = "StatusEffects"
		add_child(status_effect_container)

func add_modifier(modifier: EnemyModifier) -> void:
	if modifier == null:
		return

	if modifier.get_parent() != null:
		modifier.get_parent().remove_child(modifier)

	modifier_container.add_child(modifier)
	modifier.setup(self)
	modifiers.append(modifier)
	modifier.on_added()
	recalculate_stats()
	refresh_enemy_ui()

func remove_modifier(modifier: EnemyModifier) -> void:
	if modifier == null:
		return

	if modifiers.has(modifier):
		modifiers.erase(modifier)

	modifier.on_removed()

	if is_instance_valid(modifier) and modifier.get_parent():
		modifier.get_parent().remove_child(modifier)

	recalculate_stats()
	refresh_enemy_ui()

func has_modifier_id(modifier_id: String) -> bool:
	for modifier in modifiers:
		if is_instance_valid(modifier) and modifier.get_modifier_id() == modifier_id:
			return true
	return false

func _find_mergeable_status_effect(new_effect: EnemyStatusEffect) -> EnemyStatusEffect:
	for existing_effect in status_effects:
		if not is_instance_valid(existing_effect):
			continue

		if existing_effect.should_merge_with(new_effect):
			return existing_effect

	return null

func add_status_effect(effect: EnemyStatusEffect) -> void:
	if effect == null:
		return

	if not can_receive_status_effect(effect):
		if is_instance_valid(effect):
			effect.queue_free()
		return

	var existing_effect := _find_mergeable_status_effect(effect)
	if existing_effect != null:
		existing_effect.on_reapplied(effect)
		recalculate_stats()
		refresh_enemy_ui()

		if is_instance_valid(effect):
			effect.queue_free()

		return

	if effect.get_parent() != null:
		effect.get_parent().remove_child(effect)

	status_effect_container.add_child(effect)
	effect.setup(self, effect.duration)
	status_effects.append(effect)
	effect.on_added()

	recalculate_stats()
	refresh_enemy_ui()

func remove_status_effect(effect: EnemyStatusEffect) -> void:
	if effect == null:
		return

	if status_effects.has(effect):
		status_effects.erase(effect)

	effect.on_removed()

	if is_instance_valid(effect) and effect.get_parent():
		effect.get_parent().remove_child(effect)

	if is_instance_valid(effect):
		effect.queue_free()

	recalculate_stats()
	refresh_enemy_ui()

func remove_status_effects_by_id(effect_id: String) -> void:
	var to_remove: Array[EnemyStatusEffect] = []

	for effect in status_effects:
		if is_instance_valid(effect) and effect.get_effect_id() == effect_id:
			to_remove.append(effect)

	for effect in to_remove:
		remove_status_effect(effect)

func has_status_effect_id(effect_id: String) -> bool:
	for effect in status_effects:
		if is_instance_valid(effect) and effect.get_effect_id() == effect_id:
			return true
	return false

func has_status_effect_type(script: Script) -> bool:
	for effect in status_effects:
		if is_instance_valid(effect) and effect.get_script() == script:
			return true
	return false

func get_status_effect_by_id(effect_id: String) -> EnemyStatusEffect:
	for effect in status_effects:
		if is_instance_valid(effect) and effect.get_effect_id() == effect_id:
			return effect
	return null

func get_status_effects_by_id(effect_id: String) -> Array[EnemyStatusEffect]:
	var results: Array[EnemyStatusEffect] = []

	for effect in status_effects:
		if is_instance_valid(effect) and effect.get_effect_id() == effect_id:
			results.append(effect)

	return results

func get_status_effects_of_type(script: Script) -> Array[EnemyStatusEffect]:
	var results: Array[EnemyStatusEffect] = []

	for effect in status_effects:
		if is_instance_valid(effect) and effect.get_script() == script:
			results.append(effect)

	return results

func get_active_negative_status_effects() -> Array[EnemyStatusEffect]:
	var results: Array[EnemyStatusEffect] = []

	for effect in status_effects:
		if is_instance_valid(effect) and effect.is_negative_effect():
			results.append(effect)

	return results

func process_modifiers(delta: float) -> void:
	for modifier in modifiers:
		if is_instance_valid(modifier):
			modifier.on_enemy_process(delta)

func process_status_effects(delta: float) -> void:
	var expired_effects: Array[EnemyStatusEffect] = []

	for effect in status_effects:
		if not is_instance_valid(effect):
			continue

		effect.on_enemy_process(delta)

		if effect.is_expired():
			expired_effects.append(effect)

	for effect in expired_effects:
		remove_status_effect(effect)

func update_navigation_target() -> void:
	if is_instance_valid(target) and path_update_timer >= update_interval:
		nav2d.target_position = target.global_position
		path_update_timer = 0.0

func move_via_navigation_toward_target(delta: float, stop_distance: float = 40.0) -> void:
	if not can_move or dead or spawning or is_pushed:
		return

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.STUNNED:
		return

	if not is_instance_valid(target):
		return

	if global_position.distance_to(target.global_position) < stop_distance:
		return

	update_navigation_target()

	var next_position = nav2d.get_next_path_position()
	if next_position != Vector2.ZERO:
		global_position = global_position.move_toward(next_position, move_speed * delta)

func move_directly_toward_target(delta: float, stop_distance: float = 40.0) -> void:
	if not can_move or dead or spawning or is_pushed:
		return

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.STUNNED:
		return

	if not is_instance_valid(target):
		return

	if global_position.distance_to(target.global_position) < stop_distance:
		return

	global_position = global_position.move_toward(target.global_position, move_speed * delta)

func move_away_from_target(delta: float, desired_distance: float) -> void:
	if not can_move or dead or spawning or is_pushed:
		return

	if current_state == EnemyState.ATTACKING or current_state == EnemyState.STUNNED:
		return

	if not is_instance_valid(target):
		return

	var distance = global_position.distance_to(target.global_position)
	if distance >= desired_distance:
		return

	var direction = (global_position - target.global_position).normalized()
	global_position += direction * move_speed * delta

func begin_attack_state() -> void:
	if dead:
		return

	attack_started.emit()

	if animation_player.has_animation("attack"):
		animation_player.speed_scale = attack_animation_speed
		animation_player.play("attack")

func animation_attack_hit() -> void:
	if dead or current_state != EnemyState.ATTACKING:
		return

	resolve_attack_hit()
	attack_hit.emit()

func play_walk_animation() -> void:
	if not is_instance_valid(animation_player):
		return

	if animation_player.has_animation("walk"):
		animation_player.speed_scale = walk_animation_speed
		animation_player.play("walk")

func update_current_animation_speed() -> void:
	if not is_instance_valid(animation_player):
		return

	var current_anim := animation_player.current_animation

	if current_anim == "walk":
		animation_player.speed_scale = walk_animation_speed
	elif current_anim == "attack":
		animation_player.speed_scale = attack_animation_speed

func resolve_attack_hit() -> void:
	pass

func animation_attack_finished() -> void:
	if dead:
		return

	attack_cooldown_timer = attack_cooldown
	animation_player.speed_scale = 1.0
	attack_finished.emit()

	play_walk_animation()
	set_state(EnemyState.IDLE)

func update_health_bar_position() -> void:
	if not is_instance_valid(health_bar):
		return

	if not is_instance_valid(health_bar_anchor):
		return

	health_bar.global_position = health_bar_anchor.global_position

func apply_stun(duration: float) -> void:
	if dead:
		return

	var existing_effect = get_status_effect_by_id("stun")
	if existing_effect != null:
		existing_effect.duration = max(existing_effect.duration, existing_effect.elapsed + duration)
		recalculate_stats()
		refresh_enemy_ui()
		return

	var stun = StunEffect.new()
	stun.duration = duration
	stun.source_id = "stun"
	add_status_effect(stun)
	refresh_enemy_ui()

func health_below_zero() -> void:
	if health <= 0.0:
		die()

func take_damage(amount: float, damage_type: int = DamageBatcher.DamageType.NORMAL, _source: String = "") -> void:
	if dead or invulnerable:
		return

	health -= amount
	health = max(health, 0.0)

	if health_bar:
		health_bar.value = health

	damage_batcher.add_damage(amount, damage_type)

	if health <= 0.0:
		die()

func push_back(strength: float) -> void:
	is_pushed = true
	push_strength = strength
	pushback_timer = 0.0

func catch_up() -> void:
	catchup_timer = 0.0

	if not is_instance_valid(player_model):
		return

	if global_position.distance_to(player_model.global_position) >= 1500.0:
		move_speed = 1000.0
	else:
		recalculate_stats()

func random_drop() -> void:
	if suppress_random_drops:
		return

	if item_rolled or value == 0:
		return

	item_rolled = true

	var ran = randf_range(0.0, 1.0)
	if variant == EnemyManager.variant.MONEY:
		ran = 0.0

	if ran <= 0.1:
		value = 1
		if ran <= 0.05:
			value = 5
		if ran <= 0.015:
			value = 10

		var money = MONEY_DROP.instantiate()
		money.global_position = global_position
		money.value = value
		EnemyManager.magnet_all.connect(money._on_magnet_call)
		get_tree().current_scene.add_child(money)

func apply_visual_scale() -> void:
	if not is_instance_valid(container):
		return

	var facing_sign := 1.0
	if container.scale.x < 0.0:
		facing_sign = -1.0

	container.scale = Vector2(visual_scale * facing_sign, visual_scale)

func die() -> void:
	if dead:
		return

	dead = true
	spawning = false
	current_state = EnemyState.DEAD

	for modifier in modifiers:
		if is_instance_valid(modifier):
			modifier.on_enemy_died()

	for effect in status_effects:
		if is_instance_valid(effect):
			effect.on_enemy_died()

	random_drop()
	clear_groups()
	damage_batcher.clear_all()

	if is_instance_valid(area_2d):
		for col in area_2d.get_children():
			col.set_deferred("disabled", true)

	EnemyManager.unregister(self)

	if animation_player.has_animation("die"):
		animation_player.play("die")

	died.emit()

	if health_bar:
		health_bar.queue_free()

	if shadow:
		shadow.hide()

	await get_tree().create_timer(5.0).timeout
	queue_free()

func refresh_status_effect(effect_id: String, new_duration: float, property_updates: Dictionary = {}) -> bool:
	var effect = get_status_effect_by_id(effect_id)
	if effect == null:
		return false

	effect.duration = max(effect.duration, effect.elapsed + new_duration)

	for key in property_updates.keys():
		effect.set(key, property_updates[key])

	recalculate_stats()
	refresh_enemy_ui()
	return true

func refresh_status_effect_duration(effect_id: String, new_duration: float) -> bool:
	var effect = get_status_effect_by_id(effect_id)
	if effect == null:
		return false

	effect.duration = max(effect.duration, effect.elapsed + new_duration)
	refresh_enemy_ui()
	return true

func _build_status_effect_icon_data() -> Array:
	var effect_data: Array = []

	for effect in status_effects:
		if not is_instance_valid(effect):
			continue

		if not effect.has_method("get_icon"):
			continue

		var icon: Texture2D = effect.get_icon()
		if icon == null:
			continue

		var stacks := 1
		if effect.has_method("get_stack_count"):
			stacks = effect.get_stack_count()

		effect_data.append({
			"texture": icon,
			"stacks": stacks
		})

	return effect_data

func refresh_enemy_ui() -> void:
	if not is_instance_valid(health_bar):
		return

	var modifier_icons: Array[Texture2D] = []
	for modifier in modifiers:
		if not is_instance_valid(modifier):
			continue

		var icon := modifier.get_modifier_icon()
		if icon != null:
			modifier_icons.append(icon)

	var effect_icon_data := _build_status_effect_icon_data()

	if health_bar.has_method("set_modifier_icons"):
		health_bar.set_modifier_icons(modifier_icons)

	if health_bar.has_method("set_status_effect_icons"):
		health_bar.set_status_effect_icons(effect_icon_data)

func _die_from_manager() -> void:
	value = 0
	health = 0

func clear_groups() -> void:
	for group in get_groups():
		remove_from_group(group)

func _free_node(anim_name: String) -> void:
	if anim_name == "die":
		queue_free()

func _optimize() -> void:
	shadow.visible = false
