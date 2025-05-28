extends BaseItem

var elapsed_time := 0.0
var bleed_tick := 1
const item_name = "Silly Teeth"
const item_description = "Every attack adds a bleed stack. Each bleed stack deals 1 damage per second. This effect is 4 times less effective against certain enemies and bosses."
var tags = ["bleed"]
var rarity = 1
var item_icon = preload("res://items/icons/silly_teeth.png")
var file_name = "res://items/scripts/1/silly_teeth.gd"
var boss_modifier = 0.25

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= bleed_tick:
		elapsed_time -= bleed_tick
		timed_bleed()

func proc(target, any):
	target.bleed_stacks += 1
	if not target.debuffs.has(debuff.Debuff.BLEED):
		target.debuffs.append(debuff.Debuff.BLEED)
		target.apply_debuff()


func timed_bleed():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.is_in_group("boss") or enemy.is_in_group("elite"):
			enemy.take_damage(round(enemy.bleed_stacks * boss_modifier), DamageBatcher.DamageType.BLEED)
		else:
			enemy.take_damage(enemy.bleed_stacks, DamageBatcher.DamageType.BLEED)
