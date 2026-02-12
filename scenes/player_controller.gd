extends Node2D

@export var iframe_duration = 1
@onready var player = TestPlayer

var hold_click_timer := Timer.new()
@export var position_map := []
var show_attack_range = true
var attack_radius_x = 600
var attack_radius_y = 420
var base_attack_damage = 10
var base_max_hp = 100.0
var attack_range_multiplier = 1.0
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
var base_passive_regen = 0.2 # 1 HP / 5 seconds
var passive_regen = 0.2
var regen_timer = 0.0
var luck
var base_luck = 0
var overshields = 0
var overshields_cap = 0
var overshield_timer = 0.0
signal reset
var dash_animation_timer = 0.0
var processed_items = []
var inventory: Array = []
var base_movement_speed = 210.0
var movement_speed = 0.0
var last_enemy_attacked = null # For use in chain attacks
var bleed_timer = 0
var bleed_cooldown = 1
var attacking = false
var dead = false

func _ready():
	luck = base_luck
	clicks_per_second = base_clicks_per_second
	current_hp = base_max_hp
	total_armor = base_armor
	max_hp = base_max_hp
	movement_speed = base_movement_speed
	# Set up the click-hold timer
	hold_click_timer.wait_time = 1.0 / clicks_per_second # 6.2 clicks per second
	hold_click_timer.one_shot = false
	hold_click_timer.autostart = false
	hold_click_timer.timeout.connect(attack)
	add_child(hold_click_timer)
	hold_click_timer.start()
	overshields_cap = max_hp * 0.3

func _process(delta: float) -> void:
	if get_enemies_in_range(player.global_position).size() > 0:
		attacking = true
	else:
		attacking = false
	if current_hp <= 0:
		hold_click_timer.stop()
		current_hp = 0
	dash_animation_timer += delta
	regen_timer += delta
	overshield_timer += delta
	bleed_timer += delta
	
	if bleed_timer >= bleed_cooldown:
		bleed_timer = 0
		timed_bleed()
	
	if overshields > overshields_cap:
		overshields = overshields_cap
	if overshields < 0:
			overshields = 0
	
	if overshields > 0 and overshield_timer >= 0.333333:
		overshield_timer = 0.0
		overshields -= 1
	
	
	if regen_timer >= 1.0 and TestPlayer.visible and not current_hp <= 0:
		heal(passive_regen)
		regen_timer = 0
	
	if Input.is_action_just_pressed("Pause") and not GameState.on_start_screen:
		get_tree().paused = not get_tree().paused
	
	if get_nearest_enemy():
		Crosshair.target_enemy(get_nearest_enemy())
	else:
		Crosshair.hide_crosshair()
	
func attack() -> void:
	if dead:
		return
	var closest_enemy = null
	var shortest_distance = INF
	
	for node in get_enemies_in_range(player.global_position):
		if node and node.is_inside_tree():
			var distance = player.global_position.distance_to(node.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = node

	if closest_enemy:
		last_enemy_attacked = closest_enemy
		var result = calculate_damage()
		spawn_slingshot_projectile(closest_enemy, result)

func attack_specific_enemy(enemy, damage_multiplier: float = 1.0, damage_type = DamageBatcher.DamageType.NORMAL):
	if dead:
		return
	var result = calculate_damage(damage_type, damage_multiplier)
	if enemy:
		enemy.take_damage(result.damage, result.crit, "Player Attack")
		proc_items(enemy)

func attack_all_enemies():
	if dead:
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		last_enemy_attacked = enemy
		var result = calculate_damage()
		enemy.take_damage(result.damage, result.crit, "Player Global Attack")
		proc_items(enemy)

func get_nearest_enemy():
	var closest_enemy = null
	var shortest_distance = INF
	for enemy in get_enemies_in_range(player.global_position):
		if enemy and enemy.is_inside_tree():
			var distance = player.global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = enemy
	return closest_enemy


func attack_nearest_enemy(last_attacked_enemy: Node) -> void:
	if dead:
		return
	if last_attacked_enemy:  # Only proceed if there's a valid enemy
		var nearest_enemy = null
		var shortest_distance = INF

		# Find the nearest enemy to the last attacked enemy
		for node in get_enemies_in_range(player.global_position):
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
			processed_items.append(item)
			add_child(item)
		item.set_process(true)  # <-- ensure it's activ
	PauseMenu.update_inventory_display()
	
	if item.item_name == "Shielding Scythe":
		GameState.scythe_amount += 1

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
	movement_speed = base_movement_speed
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
			passive_regen += item.get_regen()
		if item.has_method("get_cps"):
			clicks_per_second += item.get_cps()
			hold_click_timer.wait_time = 1.0 / clicks_per_second
		if item.has_method("get_movement_speed"):
			movement_speed += item.get_movement_speed() 
	max_hp = max_hp * (1 + max_hp_percentage)
	if inventory.size() > 0 and inventory.back().has_method("heal"):
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
	if current_hp <= 0:
		return
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
		if item.has_method("starter_proc"):
				item.starter_proc(target, source_item)
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

func proc_starter_items(target, source_item: BaseItem = null):
	for item in inventory:
		if item.has_method("starter_proc"):
			item.starter_proc(target, source_item)

func add_cash(amount) -> void:
	cash += amount

func get_block_chance():
	var block_percent = 0.0
	for item in inventory:
		if "block_percent" in item:
			block_percent += item.block_percent
	return block_percent

func reset_to_defaults():
	difficulty = 0
	inventory.clear()
	
	hold_click_timer.start()
	cash = 0
	passive_regen = 1.0
	overshields = 0
	regen_timer = 0.0
	base_luck = 0
	luck = base_luck
	current_hp = base_max_hp
	movement_speed = base_movement_speed
	update_modifiers()
	HealthBar.dead = false
	dead = false
	ItemDatabase.reset_items()
	TestPlayer.reset_player_model()
	GameState.reset_all()
	MapManager.reset_defaults()
	PauseMenu.update_inventory_display()
	PauseMenu.update_labels()
	reset.emit()
	free_items()
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

func timed_bleed():
	var bleed_dmg = 0
	for item in inventory:
			if "bleed_tick" in item:
				bleed_dmg += item.bleed_tick
	if bleed_dmg == 0:
		return
	for enemy in get_tree().get_nodes_in_group("bleeding"):
		enemy.take_damage(enemy.bleed_stacks * bleed_dmg, DamageBatcher.DamageType.BLEED, "Bleed Stack Damage")

func free_items():
	for item in processed_items:
		item.queue_free()

func is_in_attack_oval(point: Vector2, center: Vector2) -> bool:
	var dx = (point.x - center.x) / attack_radius_x
	var dy = (point.y - center.y) / attack_radius_y
	return (dx * dx + dy * dy) <= 1.0

func get_enemies_in_range(center: Vector2):
	var in_range = []
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy or not enemy.is_inside_tree():
			continue

		if is_in_attack_oval(enemy.global_position, center):
			in_range.append(enemy)

	return in_range

func spawn_slingshot_projectile(target, result, size: float = 1.0, damage_source: String = "Player Attack", can_proc: bool = true):
	var projectile_scene = preload("res://characters/goblin/slingshot_projectile.tscn")
	var projectile = projectile_scene.instantiate()
	projectile.global_position = player.get_sling_position()
	var target_position = target.global_position 
	if target.find_child("pivot", 1, 1):
		target_position = target.find_child("pivot", 1, 1).global_position
	target_position += Vector2(randf_range(-30, 30), randf_range(-30, 30))
	projectile.target_position = target_position
	projectile.scale *= size
	projectile.on_reach = Callable(self, "_deal_damage_to_enemy").bind(target, result, damage_source, can_proc)
	get_tree().current_scene.add_child(projectile)

func _deal_damage_to_enemy(enemy, damage_result, damage_source: String = "Player Attack", can_proc: bool = true):
	if enemy and enemy.is_inside_tree():
		enemy.take_damage(damage_result.damage, damage_result.crit, damage_source)
		if can_proc:
			proc_items(enemy)
