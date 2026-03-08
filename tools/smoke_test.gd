extends SceneTree

func _initialize() -> void:
	# Read main scene path from project settings
	var main_scene_path = ProjectSettings.get_setting("application/run/main_scene")

	if main_scene_path == null or str(main_scene_path) == "":
		push_error("Smoke test failed: application/run/main_scene is not set.")
		quit(1)
		return

	var packed: PackedScene = load(main_scene_path)
	if packed == null:
		push_error("Smoke test failed: could not load main scene: %s" % str(main_scene_path))
		quit(1)
		return

	var inst = packed.instantiate()
	if inst == null:
		push_error("Smoke test failed: could not instantiate main scene: %s" % str(main_scene_path))
		quit(1)
		return

	get_root().add_child(inst)

	# Let one frame pass (helps catch immediate runtime errors)
	call_deferred("_finish_ok")

func _finish_ok() -> void:
	quit(0)
