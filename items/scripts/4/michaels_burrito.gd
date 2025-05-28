extends BaseItem
const item_name = "Michael's Burrito"
const item_description = "Killing an enemy has a 10% chance to drop a blood puddle that deals 20% of your damage every second. The blood is yours, not theirs. (colitis)"
const item_icon = preload("res://items/icons/michaels_burrito.png")
const tags = []
const rarity = 4
var file_name = "res://items/scripts/4/michaels_burrito.gd"
var player_body = TestPlayer
static var percent_dmg = 0.2
static var puddle_chance = 0.1
var puddle := preload("res://items/misc/burrito_puddle.tscn")


func proc(target: Node, source_item: BaseItem = null):
	if not player or not target or not is_instance_valid(target):
		return

	var tree = player.get_tree() if player.is_inside_tree() else null
	if not tree:
		return

	var strength = 0
	target.set_meta("burrito", true)

static func calculate_puddle_chance():
	var rand = PlayerController.calculate_luck()
	return {
		"random_value": rand,
		"puddle_chance": puddle_chance
	}
