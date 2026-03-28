extends BaseItem

const item_name = "Silly Teeth"
const item_description = "Every attack adds a bleed stack. Each bleed stack deals 1 damage per second for 10 seconds."
var tags = ["bleed"]
var rarity = 1
var item_icon = preload("res://items/icons/silly_teeth.png")
var file_name = "res://items/scripts/1/silly_teeth.gd"

var bleed_duration := 10.0
var bleed_damage_per_stack := 1.0

func proc(target: Node, _source_item: BaseItem = null):
	if not player or not is_instance_valid(target):
		return

	if not target.has_method("add_status_effect"):
		return

	var bleed = target.get_status_effect_by_id("bleed") if target.has_method("get_status_effect_by_id") else null
	if bleed != null and bleed is BleedEffect:
		target.refresh_status_effect("bleed", bleed_duration)
		bleed.add_stack(1, bleed_damage_per_stack)
		return

	var effect = BleedEffect.new()
	effect.duration = bleed_duration
	effect.damage_per_stack = bleed_damage_per_stack
	effect.stack_count = 1
	target.add_status_effect(effect)
