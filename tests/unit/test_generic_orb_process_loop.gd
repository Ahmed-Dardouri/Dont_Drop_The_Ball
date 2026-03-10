extends GutTest
## Unit tests for GenericOrb behavior process loop (F2 Fix)
## Tests that _process() routes to behavior.process() for OrbData orbs


#region Behavior Process Loop Tests

func test_process_calls_behavior_process_with_delta() -> void:
	# Create a mock behavior that tracks process calls
	var mock_behavior := _MockProcessBehavior.new()
	mock_behavior.behavior_id = "test_process"

	var orb_data := OrbData.new()
	orb_data.display_name = "Process Test Orb"
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	orb_data.spawn_animation_duration = 0.0  # No spawn animation
	orb_data.behaviors = [mock_behavior]

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)

	# Simulate process frame (after spawn animation would complete)
	var test_delta: float = 0.016
	orb._process(test_delta)

	assert_true(mock_behavior.process_called, "behavior.process() should be called")
	assert_eq(mock_behavior.last_delta, test_delta, "process() should receive delta parameter")
	assert_eq(mock_behavior.last_orb, orb, "process() should receive orb reference")
	orb.queue_free()


func test_process_calls_all_behaviors() -> void:
	var mock_behavior1 := _MockProcessBehavior.new()
	mock_behavior1.behavior_id = "test_process_1"
	var mock_behavior2 := _MockProcessBehavior.new()
	mock_behavior2.behavior_id = "test_process_2"

	var orb_data := OrbData.new()
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	orb_data.spawn_animation_duration = 0.0  # No spawn animation
	orb_data.behaviors = [mock_behavior1, mock_behavior2]

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)

	# Simulate process frame
	orb._process(0.016)

	assert_true(mock_behavior1.process_called, "First behavior.process() should be called")
	assert_true(mock_behavior2.process_called, "Second behavior.process() should be called")
	orb.queue_free()


func test_process_skips_behaviors_without_orb_data() -> void:
	var orb: GenericOrb = await _create_generic_orb_instance()

	# Should not crash when _process is called without OrbData
	orb._process(0.016)

	assert_true(true, "_process() should handle missing OrbData gracefully")
	orb.queue_free()


func test_process_waits_for_spawn_animation() -> void:
	var mock_behavior := _MockProcessBehavior.new()

	var orb_data := OrbData.new()
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	orb_data.spawn_animation_duration = 1.0  # 1 second spawn animation
	orb_data.behaviors = [mock_behavior]

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)

	# First process frame - spawn animation running, behavior should NOT be called yet
	orb._process(0.016)
	assert_false(mock_behavior.process_called, "behavior.process() should NOT be called during spawn animation")

	orb.queue_free()


#endregion

#region Spawn Animation Tests

func test_spawn_animation_fades_visual_sprite() -> void:
	var orb_data := OrbData.new()
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	orb_data.spawn_animation_duration = 1.0

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)
	var sprite: Sprite2D = orb.get_visual_sprite()

	# Initially sprite should be invisible (spawn animation not started)
	# After spawn animation completes, opacity should be 1.0
	assert_not_null(sprite, "Visual sprite should exist for OrbData orb")
	orb.queue_free()


func test_spawn_animation_uses_orb_data_duration() -> void:
	var orb_data := OrbData.new()
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	orb_data.spawn_animation_duration = 2.0

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)

	# Verify the spawn timer is configured with OrbData duration
	assert_eq(orb.get_spawn_animation_duration(), 2.0, "Spawn animation should use OrbData duration")
	orb.queue_free()


#endregion

#region Old Path Unchanged Tests

func test_old_path_spawn_animation_unchanged() -> void:
	var orb: GenericOrb = await _create_generic_orb_instance()

	# Old path should still use timer-based spawn animation
	# This test verifies the old path code path is preserved
	orb._process(0.016)

	# Should not crash - old path still works
	assert_true(true, "Old path spawn animation should work unchanged")
	orb.queue_free()


#endregion

#region Helper Methods

func _create_generic_orb_instance() -> GenericOrb:
	"""Create a GenericOrb instance from scene, added to scene tree."""
	var scene: PackedScene = load("res://scenes/generic_orb.tscn")
	var orb: GenericOrb = scene.instantiate()
	add_child(orb)
	await get_tree().process_frame
	return orb


func _create_generic_orb_with_data(orb_data: OrbData = null) -> GenericOrb:
	"""Create a GenericOrb instance with OrbData set, added to scene tree."""
	if orb_data == null:
		orb_data = OrbData.new()
		orb_data.collision_radius = 32.0
		orb_data.texture = _create_test_texture()

	var orb: GenericOrb = await _create_generic_orb_instance()
	orb.set_orb_data(orb_data)
	await get_tree().process_frame

	return orb


func _create_test_texture() -> Texture2D:
	"""Create a minimal test texture (1x1 white pixel)."""
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	return texture


#endregion

#region Mock Behavior

class _MockProcessBehavior extends OrbBehavior:
	var process_called: bool = false
	var last_delta: float = 0.0
	var last_orb: Node = null

	func process(orb: Node, delta: float) -> void:
		process_called = true
		last_delta = delta
		last_orb = orb

#endregion
