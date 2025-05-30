extends Node

@export var position = 2
@export var iframe_duration = 1
@onready var player = TestPlayer

var hold_click_timer := Timer.new()
@export var position_map := []
var base_attack_damage = 10
var base_max_hp = 100.0
var max_hp = 0.0
var max_hp_percentage = 1.0
var base_armor = 1
var additional_dmg = 0
var mult_dmg = 0
var total_armor
var current_hp = 0.0
var base_crit_chance = 0.01
var base_crit_damage = 1.5
var crit_chance = 0.01
var crit_damage = 1.5
var damage = base_attack_damage
var cash = 0
var difficulty = 0
var paused = false
var base_clicks_per_second = 6.0
var clicks_per_second
var base_passive_regen = 1.0
var passive_regen = 1.0
var regen_timer = 0.0
var luck
var base_luck = 0
var overshields = 0
var overshields_cap = 0
var overshield_timer = 0.0

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
	overshields_cap = max_hp * 0.3

func _process(delta: float) -> void:
	dash_animation_timer += delta
	regen_timer += delta
	overshield_timer += delta
	
	if overshields > overshields_cap:
		overshields = overshields_cap
	if overshields < 0:
			overshields = 0
	
	if overshields > 0 and overshield_timer >= 0.333333:
		overshield_timer = 0.0
		overshields -= 1
	
	
	if regen_timer >= 1.0 and TestPlayer.visible:
		heal(passive_regen)
		regen_timer = 0
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = not get_tree().paused
	
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
		if position >= 1:
			player.animation_player.play("move_up")
		dash_animation_timer = 0
	elif Input.is_action_just_pressed("down") and not TestPlayer.dead:
		position += 1
		if position <= position_map.size():
			player.animation_player.play("move_down")
		dash_animation_timer = 0
	if position < 1:
		position = 1
	elif position > position_map.size():
		position = position_map.size()
	
	if not position_map.is_empty():
		var pos_node = position_map[position-1]
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
		item.set_process(true)  # <-- ensure it's activ
	PauseMenu.update_inventory_display()
	
	if item.item_name == "Shielding Scythe":
		GameState.scythe_amount += 1
	print("Scythes: " + str(GameState.scythe_amount))

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
	PauseMenu.update_labels()
	overshields_cap = max_hp * 0.3
	HealthBar.progress_bar.max_value = overshields_cap


func calculate_damage(damage_type : int = DamageBatcher.DamageType.NORMAL, specific_multiplier : float = 1.0 ):
	damage = (base_attack_damage + additional_dmg) * specific_multiplier
	damage *= (mult_dmg + 1)
	var crit_roll = calculate_luck()
	var is_crit = damage_type
	if crit_roll <= crit_chance:
		damage = round(damage*crit_damage) #Crit damage
	else:
		damage = round(damage) #Crit damage
	return {
		"damage": damage,
		"crit": is_crit
	}

func take_damage(damage, penetration) -> void:
	var block = calculate_luck()
	if block <= get_block_chance():
		var miss = preload("res://items/misc/miss.tscn").instantiate()
		miss.global_position = TestPlayer.global_position + Vector2(randf_range(-50.0, 10.0), randf_range(-80, -40.0))
		get_tree().current_scene.add_child(miss)
		return
	var damage_reduction = (total_armor - penetration)/(100.0 + total_armor - penetration)
	damage *= (1 - damage_reduction)
	damage = round(damage)
	var leftover_damage = overshields - damage
	overshields -= damage
	if leftover_damage < 0:
		current_hp -= abs(leftover_damage)

func heal(amount):
	current_hp += amount
	if current_hp >= max_hp:
		current_hp = max_hp

func proc_items(target, source_item: BaseItem = null):
	var proc_count = 1
	for item in inventory:
		if item.item_name == "Parrot":
			if item.get_trigger():
				proc_count += 1
	var used_thunderbolt = false
	var used_lava_cake = false
	var used_bowling_ball = false
	for item in inventory:
		for i in range(proc_count):
			if item.has_method("proc"):
				if item.tags.has("thunderbolt") and not used_thunderbolt:
					item.proc(target, source_item)
					used_thunderbolt = true
				elif item.item_name == "Molten Lava Cake" and not used_lava_cake:
					item.proc(target, source_item)
					used_lava_cake = true
				elif item.item_name == "Bowling Ball" and not used_bowling_ball:
					item.proc(target, source_item)
					used_bowling_ball = true
				else:
					item.proc(target, source_item)


func add_cash(amount) -> void:
	cash += amount

func reset_positions():
	position_map.clear()
	if get_tree().get_root().find_child("Positions", true, false):
		for child in get_tree().get_root().find_child("Positions", true, false).get_children():
			position_map.append(child)
		position = 1

func get_block_chance():
	var count = 0
	for item in inventory:
		if item.item_name == "Rougher Times":
			count += 1
	if count == 0:
		return 0
	else:
		return 1 - pow(0.95, count)

func reset_to_defaults():
	base_attack_damage = 10
	base_max_hp = 100.0
	max_hp = 0.0
	max_hp_percentage = 1.0
	base_armor = 1
	additional_dmg = 0
	mult_dmg = 0
	current_hp = 0.0
	base_crit_chance = 0.01
	base_crit_damage = 1.5
	crit_chance = 0.01
	crit_damage = 1.5
	damage = base_attack_damage
	cash = 0
	difficulty = 0
	base_clicks_per_second = 6.0
	clicks_per_second
	base_passive_regen = 1.0
	passive_regen = 1.0
	regen_timer = 0.0
	base_luck = 0
	luck = base_luck
	clicks_per_second = base_clicks_per_second
	current_hp = base_max_hp
	total_armor = base_armor
	max_hp = base_max_hp
	GameState.endless_mode = false
	GameState.endless_counter = 0
	MapState.reset_map()
	SceneManager.switch_to_scene("res://start_scene.tscn")

func grant_shields(amount):
	overshields += amount

func calculate_luck():
	var chance = randf()
	if luck > 0:
		for i in range(luck):
			var rand = randf()
			if rand < chance:
				chance = rand
		return chance
	else:
		return chance
