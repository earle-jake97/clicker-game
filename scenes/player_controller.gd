extends Node

@export var position = 2
@export var iframe_duration = 1
@onready var player = TestPlayer
const PLAYER_IDLE = preload("res://sprites/test_player/new_player_idle.png")
const PLAYER_MOVE = preload("res://sprites/test_player/new_player_move.png")

var hold_click_timer := Timer.new()
var position_map := {}
var base_attack_damage = 10
var base_max_hp = 100.0
var max_hp
var max_hp_percentage = 1.0
var base_armor = 1
var additional_dmg = 0
var mult_dmg = 0
var total_armor
var current_hp
var base_crit_chance = 0.01
var base_crit_damage = 1.5
var crit_chance = 0.01
var crit_damage = 1.5
var damage = base_attack_damage
var cash = 10
var difficulty = 0
var paused = false
var base_clicks_per_second = 6.0
var clicks_per_second
var base_passive_regen = 1.0
var passive_regen = 1.0
var regen_timer = 0.0
var luck
var base_luck = 0

var dash_animation_timer = 0.0

var inventory: Array = []

var last_enemy_attacked = null # For use in chain attacks


func _ready():
	luck = base_luck
	clicks_per_second = base_clicks_per_second
	current_hp = base_max_hp
	total_armor = base_armor
	max_hp = base_max_hp
	# Set up the click-hold timer
	hold_click_timer.wait_time = 1.0 / clicks_per_second # 6.2 clicks per second
	hold_click_timer.one_shot = false
	hold_click_timer.autostart = false
	hold_click_timer.timeout.connect(attack)
	add_child(hold_click_timer)
	hold_click_timer.start()

func _process(delta: float) -> void:
	dash_animation_timer += delta
	regen_timer += delta
	
	if regen_timer >= 1.0 and TestPlayer.visible:
		heal(passive_regen)
		regen_timer = 0
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = not get_tree().paused
	if GameState.leave_shop_triggered:
		Tooltip.hide_tooltip()
	if dash_animation_timer >= 0.1:
		player.sprite_2d.texture = PLAYER_IDLE
	
	if get_nearest_enemy():
		Crosshair.target_enemy(get_nearest_enemy())
	else:
		Crosshair.hide_crosshair()

func _physics_process(delta: float) -> void:
	move_player()
	#if Input.is_action_pressed("Hold_Click"):
		#if not hold_click_timer.is_stopped():
			#return
		#hold_click_timer.start()
	#elif Input.is_action_just_released("Hold_Click"):
		#hold_click_timer.stop()
	#elif Input.is_action_just_pressed("Click"):
		#attack()

func move_player() -> void:
	if Input.is_action_just_pressed("up") and not TestPlayer.dead:
		position -= 1
		player.animation_player.play("move_up")
		player.sprite_2d.texture = PLAYER_MOVE
		dash_animation_timer = 0
	elif Input.is_action_just_pressed("down") and not TestPlayer.dead:
		position += 1
		player.animation_player.play("move_down")
		player.sprite_2d.texture = PLAYER_MOVE
		dash_animation_timer = 0
	if position < 1:
		position = 1
	elif position > 3:
		position = 3
	
	if position_map.has(position) and not GameState.on_map_screen:
		var pos_node = position_map[position]
		if pos_node and is_instance_valid(pos_node):
			player.global_position = pos_node.global_position

	
func attack() -> void:
	var closest_enemy = null
	var shortest_distance = INF
	
	for node in get_tree().get_nodes_in_group("enemy"):
		if node and node.is_inside_tree():
			var distance = player.global_position.distance_to(node.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = node

	if closest_enemy:
		last_enemy_attacked = closest_enemy
		var result = calculate_damage()
		closest_enemy.take_damage(result.damage, result.crit)
		proc_items(closest_enemy)

func attack_specific_enemy(enemy, damage_multiplier: float = 1.0, damage_type = DamageBatcher.DamageType.NORMAL):
	var result = calculate_damage(damage_type, damage_multiplier)
	if enemy:
		enemy.take_damage(result.damage, result.crit)
		proc_items(enemy)

func attack_all_enemies():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		last_enemy_attacked = enemy
		var result = calculate_damage()
		enemy.take_damage(result.damage, result.crit)
		proc_items(enemy)

func get_nearest_enemy():
	var closest_enemy = null
	var shortest_distance = INF
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy and enemy.is_inside_tree():
			var distance = player.global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = enemy
	return closest_enemy


func attack_nearest_enemy(last_attacked_enemy: Node) -> void:
	if last_attacked_enemy:  # Only proceed if there's a valid enemy
		var nearest_enemy = null
		var shortest_distance = INF

		# Find the nearest enemy to the last attacked enemy
		for node in get_tree().get_nodes_in_group("enemy"):
			if node and node.is_inside_tree() and node != last_attacked_enemy:
				var distance = last_attacked_enemy.global_position.distance_to(node.global_position)
				if distance < shortest_distance:
					shortest_distance = distance
					nearest_enemy = node

		# If we found a nearest enemy, attack it
		if nearest_enemy:
			last_enemy_attacked = nearest_enemy
			var result = calculate_damage()
			nearest_enemy.take_damage(round(result.damage * 0.7), result.crit)
			

func add_item(item: BaseItem):
	inventory.append(item)
	item.on_pickup(self)
	update_modifiers()
	
	if item.has_method("_process"):
		if not item.is_inside_tree():
			add_child(item)
		item.set_process(true)  # <-- ensure it's active

func update_modifiers():
	additional_dmg = 0
	mult_dmg = 0.0
	max_hp_percentage = 0.0
	max_hp = base_max_hp
	total_armor = base_armor
	crit_chance = base_crit_chance
	crit_damage = base_crit_damage
	clicks_per_second = base_clicks_per_second
	passive_regen = base_passive_regen
	luck = base_luck
	for item in inventory:
		if item.has_method("get_luck"):
			luck += item.get_luck()
		if item.has_method("get_flat_attack_damage"):
			additional_dmg += item.get_flat_attack_damage()
		if item.has_method("get_percent_attack_damage"):
			mult_dmg += item.get_percent_attack_damage()
		if item.has_method("get_crit_rate"):
			crit_chance += item.get_crit_rate()
		if item.has_method("get_crit_damage"):
			crit_damage += item.get_crit_damage()
		if item.has_method("get_flat_hp"):
			max_hp += item.get_flat_hp()
		if item.has_method("get_hp_percentage"):
			max_hp_percentage += item.get_hp_percentage()
		if item.has_method("get_armor"):
			total_armor += item.get_armor()
		if item.has_method("get_regen"):
			passive_regen += item.get_region()
		if item.has_method("get_cps"):
			clicks_per_second += item.get_cps()
			hold_click_timer.wait_time = 1.0 / clicks_per_second
	max_hp = max_hp * (1 + max_hp_percentage)
	if inventory.back().has_method("heal"):
		inventory.back().heal()

func calculate_damage(damage_type : int = DamageBatcher.DamageType.NORMAL, specific_multiplier : float = 1.0 ):
	damage = (base_attack_damage + additional_dmg) * specific_multiplier
	damage *= (mult_dmg + 1)
	var crit_roll = randf()
	for i in range(luck):
		var roll = randf()
		if roll < crit_roll:
			crit_roll = roll
	var is_crit = damage_type
	if crit_roll <= crit_chance:
		damage = round(damage*crit_damage) #Crit damage
		is_crit = DamageBatcher.DamageType.CRIT
	else:
		damage = round(damage) #Crit damage
	return {
		"damage": damage,
		"crit": is_crit
	}

func take_damage(damage, penetration) -> void:
	print(total_armor)
	var damage_reduction = (total_armor - penetration)/(100.0 + total_armor - penetration)
	damage *= (1 - damage_reduction)
	damage = round(damage)
	current_hp -= damage

func heal(amount):
	current_hp += amount
	if current_hp >= max_hp:
		current_hp = max_hp

func proc_items(target, source_item: BaseItem = null):
	var used_thunderbolt = false
	for item in inventory:
		if item.has_method("proc"):
			if item.tags.has("thunderbolt") and not used_thunderbolt:
				item.proc(target, source_item)
				used_thunderbolt = true
			elif not item.tags.has("thunderbolt"):
				item.proc(target, source_item)


func add_cash(amount) -> void:
	cash += amount

func reset_positions():
	position_map.clear()
	for pos in get_tree().get_nodes_in_group("player_positions"):
		position_map[pos.pos] = pos
