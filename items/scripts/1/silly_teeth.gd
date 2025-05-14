extends BaseItem

var elapsed_time := 0.0
var bleed_tick := 1
const item_name = "Silly Teeth"
const item_description = "Every attack adds a bleed stack. Each bleed stack deals 1 damage per second. Halved for bosses."
var tags = ["bleed"]
var rarity = 1
var item_icon = preload("res://items/icons/silly_teeth.png")
var file_name = "res://items/scripts/1/silly_teeth.gd"
var boss_modifier = 0.5

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= bleed_tick:
		elapsed_time -= bleed_tick
		timed_bleed()

func proc(enemy, any):
	enemy.bleed_stacks += 1

func timed_bleed():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.is_in_group("boss"):
			enemy.take_damage(round(enemy.bleed_stacks * boss_modifier), DamageBatcher.DamageType.BLEED)
		else:
			enemy.take_damage(enemy.bleed_stacks, DamageBatcher.DamageType.BLEED)
