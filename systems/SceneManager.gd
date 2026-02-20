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
	EnemyManager.clear_list()
	scene_switched.emit()

	var tree = get_tree()
	var root = tree.root

	if tree.current_scene:
		tree.current_scene.queue_free()

	var new_scene = target_scene_instance.instantiate()
	root.add_child(new_scene)

	await tree.process_frame

	if is_instance_valid(new_scene) and new_scene.get_parent() == root:
		tree.current_scene = new_scene
	else:
		push_warning("SceneManager: Scene invalid before set_current_scene")
