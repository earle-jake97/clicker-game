extends BaseItem
const item_name = "Repulsor"
const item_description = "Every ten seconds, generate a shield. This shield will block projectiles, and has 25 HP."
const item_icon = preload("res://items/icons/reflector.png")
const tags = []
const rarity = 3
var file_name = "res://items/scripts/3/repulsor.gd"
const BUBBLE_SHIELD = preload("uid://ctsw1qe0rylja")


var cooldown_timer := 10.0
var cooldown := 10.0

func _ready() -> void:
	connect("reset", Callable(self, "queue_free"))

func _process(delta):
	if not player:
		return
	print("Bubble state: ", GameState.bubble_shield_active, " Timer: ", cooldown_timer)
	if not GameState.bubble_shield_active and is_instance_valid(PlayerController.get_player_body()):
		cooldown_timer += delta
	
	if cooldown_timer >= cooldown:
		if is_instance_valid(PlayerController.get_player_body()):
			cooldown_timer = 0.0
			var bubble = BUBBLE_SHIELD.instantiate()
			bubble.global_position = PlayerController.get_player_body().global_position
			PlayerController.get_player_body().get_parent().add_child(bubble)
