extends BaseItem

var elapsed_time := 0.0
var bleed_tick := 1
const item_name = "Silly Teeth"
const item_description = "Every attack adds a bleed stack. Each bleed stack deals 1 damage."
var tags = ["bleed"]
var rarity = 1
var item_icon = preload("res://items/icons/silly_teeth.png")
var file_name = "res://items/scripts/1/silly_teeth.gd"

func proc(target, any):
	target.bleed_stacks += 1
	if not target.debuffs.has(debuff.Debuff.BLEED):
		target.debuffs.append(debuff.Debuff.BLEED)
		target.apply_debuff()
