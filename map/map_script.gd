extends Node2D

@onready var manager = MapManager
var choice_scene: PackedScene = preload("res://map/ChoiceSlot_Scene.tscn")
@onready var choice_container: HBoxContainer = $UI/choiceContainer
@onready var button: Button = $UI/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PauseMenu.update_labels()
	TestPlayer.visible = false
	HealthBar.button.visible = false
	HealthBar.fast_forward = false
	GameState.on_map_screen = true
	generate_choices()


func generate_choices():
	var options: int = 0
	match manager.round:
		1:
			options = randi_range(2, 3)
			populate_container(options, manager.RoomCategory.COMBAT)
		2: 
			options = 2
			populate_powerup(2)
		3: 
			options = randi_range(2, 3)
			populate_container(options, manager.RoomCategory.COMBAT)
		4: 
			options = randi_range(3, 4)
			populate_container(options, manager.RoomCategory.VARIED)
		5: 
			options = randi_range(3, 4)
			populate_container(options, manager.RoomCategory.VARIED_NO_ITEM)
		6:
			options = randi_range(2, 3)
			populate_container(options, manager.RoomCategory.DANGER)
		7:
			options = randi_range(2, 4)
			populate_container(options, manager.RoomCategory.COMBAT)
		8:
			options = randi_range(3, 4)
			populate_container(options, manager.RoomCategory.VARIED)
		9:
			options = 2
			populate_powerup(2)
		10:
			options = 1
			populate_boss_container(options)
		_:
			options = 4
			populate_container(options, manager.RoomCategory.ENDLESS)

func populate_boss_container(amount):
	for i in range(amount):
		var choice_instance = choice_scene.instantiate()
		var room_name = manager.RoomName.BOSS
		choice_instance.room_name = room_name
		choice_instance.room_sprite = RoomDatabase.get_sprite_for_room(room_name)
		choice_instance.connect("selected", Callable(self, "_on_choice_selected"))
		choice_container.add_child(choice_instance)
	return

func populate_container(amount, category):
	for i in range(amount):
		var choice_instance = choice_scene.instantiate()
		var room_name = manager.pick_room_for_category(category)
		choice_instance.room_name = room_name
		choice_instance.room_category = category
		choice_instance.room_sprite = RoomDatabase.get_sprite_for_room(room_name)
		choice_instance.connect("selected", Callable(self, "_on_choice_selected"))
		choice_container.add_child(choice_instance)
	return

func populate_powerup(amount):
	for i in range(amount):
		var choice_instance = choice_scene.instantiate()
		var room_name = manager.RoomName.SHOP
		if i == 0:
			room_name = manager.RoomName.ITEM
		choice_instance.room_name = room_name
		choice_instance.room_sprite = RoomDatabase.get_sprite_for_room(room_name)
		choice_instance.connect("selected", Callable(self, "_on_choice_selected"))
		choice_container.add_child(choice_instance)
	return

func _on_choice_selected(room_name):
	print("Selected:", room_name)
	var scene_path = RoomDatabase.get_scene_for_room(room_name)
	if scene_path == "":
		push_error("No scene mapped for room: " + str(room_name))
		return
	manager.round += 1
	PlayerController.difficulty += 1
	if GameState.endless_mode:
		PlayerController.difficulty += 1
		GameState.endless_counter += 1
	SceneManager.switch_to_scene(scene_path)


func _on_button_pressed() -> void:
	SceneManager.switch_to_scene("res://systems/test_room.tscn")
