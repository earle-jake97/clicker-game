extends Node

var target_scene_path: String = ""
var target_scene_instance: PackedScene = null
signal scene_switched()

func switch_to_scene(path: String) -> void:
	# Try to load the scene
	var packed = load(path)
	if packed is PackedScene:
		target_scene_instance = packed
		call_deferred("_do_scene_switch")
	else:
		push_error("SceneManager: Failed to load scene at path: " + path)

func _do_scene_switch():
	scene_switched.emit()
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()

	var new_scene = target_scene_instance.instantiate()
	get_tree().root.add_child(new_scene)
	await get_tree().process_frame
	
	get_tree().current_scene = new_scene
