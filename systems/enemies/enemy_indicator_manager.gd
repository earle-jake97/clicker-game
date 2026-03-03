extends Control

const ENEMY_INDICATOR = preload("uid://des8mfellrerw")
var enemies_under_10_called = false
var is_ready = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	is_ready = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.enemy_count <= 10 and not enemies_under_10_called and is_ready:
		enemies_under_10_called = true
		enable_indicators()

func enable_indicators():
	print("Manager enemy count: ", EnemyManager.get_all_enemies().size())
	for enemy in EnemyManager.get_all_enemies():
		if is_instance_valid(enemy):
			var indicator = ENEMY_INDICATOR.instantiate()
			indicator.target = enemy
			add_child(indicator)
