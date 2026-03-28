extends BaseItem

var tags = ["ice", "ice_cube", "slow"]
var rarity = 2
const item_name = "Ice Cube"
const item_description = "Your attacks slow enemy movement and attack speed by 30% for 7 seconds."
const item_icon = preload("res://items/icons/ice_cube.png")
var file_name = "res://items/scripts/2/ice_cube.gd"

var move_slow_amount := 0.30
var attack_speed_slow_amount := 0.30
var duration := 7.0

func proc(target: Node, source_item: BaseItem = null):
	if not player or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	if not target.has_method("add_status_effect"):
		return

	var refreshed_move = false
	if target.has_method("refresh_status_effect"):
		refreshed_move = target.refresh_status_effect("slow", duration, {
			"slow_percent": move_slow_amount
		})

	if not refreshed_move:
		var slow = SlowEffect.new()
		slow.duration = duration
		slow.slow_percent = move_slow_amount
		target.add_status_effect(slow)

	var refreshed_attack = false
	if target.has_method("refresh_status_effect"):
		refreshed_attack = target.refresh_status_effect("attack_speed_slow", duration, {
			"slow_percent": attack_speed_slow_amount
		})

	if not refreshed_attack:
		var attack_slow = AttackSpeedSlowEffect.new()
		attack_slow.duration = duration
		attack_slow.slow_percent = attack_speed_slow_amount
		target.add_status_effect(attack_slow)
