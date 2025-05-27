extends BaseItem

var tags = ["test_item"]
var rarity = 3
const item_name = "test_item.gd"
const item_description = "Y̶̱͆ö̸̰́ü̸͖r̸̫̊ ̸̚͜a̸͉̎t̵͕͒t̴̞̆ä̵̦c̵̖͂k̷̩̄s̶̫͝ ̸̢͐h̸̛̩a̶͉͛v̸̩͝ȩ̷̅ ̶͓̒â̵͎ ̶̦̅10% chance of adding 2x ̶̭̉d̵̢̍a̴̱̿m̷̺̿a̵͓̾g̸̲̃è̷̳,̴̠̆ ̵̘̉15% chance of adding 1.5x damage,̷̢̓ ̸̙̓ô̶̮ŗ̶̚ ̶̩̂a̶͕̎ ̷͉͗75% chance ̸̏͜o̷̞͑f̷͕̊ ̷̖̄d̷̞́ō̴̢i̶͍̓n̷̰͘g̷̝̑ ̶̎͜nothing.̶̺̎"
const item_icon = preload("res://items/icons/test_item.png")
var file_name = "res://items/scripts/3/test_item.gd"

func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	var ran = randf()
	if player.luck > 0:
		for i in range(player.luck):
			var new_roll = randf()
			if new_roll < ran:
				ran = new_roll
	if ran <= 0.1:
		target.take_damage(player.calculate_damage().damage * 2)
	elif ran <= 0.25:
		target.take_damage(player.calculate_damage().damage * 1.5)
