extends GutTest
## Unit tests for OrbSpawner OrbData integration
## Tests the bridge between OrbData array and spawn system


#region Export Variables Tests

func test_orb_data_array_export_exists() -> void:
	var spawner := OrbSpawner.new()
	add_child(spawner)

	# Check that orb_data_array property exists
	assert_true("orb_data_array" in spawner, "OrbSpawner should have orb_data_array property")
	spawner.queue_free()


func test_debug_force_orb_type_export_exists() -> void:
	var spawner := OrbSpawner.new()
	add_child(spawner)

	# Check that debug_force_orb_type property exists
	assert_true("debug_force_orb_type" in spawner, "OrbSpawner should have debug_force_orb_type property")
	spawner.queue_free()


#endregion

#region Empty Pool Tests

func test_empty_pool_returns_null() -> void:
	var spawner := OrbSpawner.new()
	spawner.orb_props = []
	spawner.orb_data_array = []
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()

	assert_null(result, "_spawn_from_props() should return null when both pools are empty")
	spawner.queue_free()


#endregion

#region OrbProps Path Tests

func test_orb_props_path_unchanged() -> void:
	var spawner := _create_spawner_with_orb_props()
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()

	assert_not_null(result, "_spawn_from_props() should return an orb from OrbProps")
	assert_true(result is GenericOrb, "Result should be a GenericOrb")
	# OrbProps orbs have _props set but no OrbData
	var orb: GenericOrb = result as GenericOrb
	assert_null(orb.get_orb_data(), "OrbProps orb should not have OrbData set")

	result.queue_free()
	spawner.queue_free()


#endregion

#region OrbData Path Tests

func test_orb_data_path_uses_adapter() -> void:
	var spawner := _create_spawner_with_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()

	assert_not_null(result, "_spawn_from_props() should return an orb from OrbData")
	assert_true(result is GenericOrb, "Result should be a GenericOrb")

	# Check that the orb has OrbData set
	var orb: GenericOrb = result as GenericOrb
	assert_not_null(orb.get_orb_data(), "Orb should have OrbData set")

	result.queue_free()
	spawner.queue_free()


func test_orb_data_orb_in_orbs_group() -> void:
	var spawner := _create_spawner_with_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()
	add_child(result)
	await get_tree().process_frame

	assert_true(result.is_in_group("orbs"), "OrbData orb should be in 'orbs' group")

	result.queue_free()
	spawner.queue_free()


#endregion

#region Combined Pool Tests

func test_combined_pool_includes_orb_data() -> void:
	var spawner := _create_spawner_with_mixed_pool()
	add_child(spawner)

	# Spawn multiple orbs and verify both types can appear
	var found_orb_data := false
	var found_orb_props := false

	for i in range(50):
		var result: Node = spawner._spawn_from_props()
		if result == null:
			continue

		var orb: GenericOrb = result as GenericOrb
		if orb.get_orb_data() != null:
			found_orb_data = true
		else:
			# OrbProps orbs don't have OrbData
			found_orb_props = true

		result.queue_free()

	# With 50 spawns from mixed pool, we should see both types with high probability
	assert_true(found_orb_data, "Should spawn at least one OrbData orb from combined pool")
	assert_true(found_orb_props, "Should spawn at least one OrbProps orb from combined pool")
	spawner.queue_free()


#endregion

#region Debug Force Spawn Tests

func test_debug_force_orb_type_overrides_selection() -> void:
	var spawner := _create_spawner_with_orb_data()
	spawner.debug_force_orb_type = "Debug Test Orb"
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()

	assert_not_null(result, "_spawn_from_props() should return orb when debug_force_orb_type matches")

	var orb: GenericOrb = result as GenericOrb
	assert_eq(orb.get_orb_data().display_name, "Debug Test Orb", "Should spawn the forced orb type")

	result.queue_free()
	spawner.queue_free()


func test_debug_force_orb_type_not_found_returns_null() -> void:
	var spawner := _create_spawner_with_orb_data()
	spawner.debug_force_orb_type = "NonExistent Orb"
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()

	assert_null(result, "_spawn_from_props() should return null when debug_force_orb_type doesn't match")
	spawner.queue_free()


func test_debug_force_orb_type_empty_uses_random() -> void:
	var spawner := _create_spawner_with_orb_data()
	spawner.debug_force_orb_type = ""
	add_child(spawner)

	var result: Node = spawner._spawn_from_props()

	assert_not_null(result, "_spawn_from_props() should return random orb when debug_force_orb_type is empty")

	result.queue_free()
	spawner.queue_free()


#endregion

#region Helper Methods

func _create_spawner_with_orb_props() -> OrbSpawner:
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")

	var props := OrbProps.new()
	props.Type = Enums.OrbType.BLUE
	spawner.orb_props = [props]
	spawner.orb_data_array = []

	return spawner


func _create_spawner_with_orb_data() -> OrbSpawner:
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")
	spawner.orb_props = []

	var orb_data := OrbData.new()
	orb_data.display_name = "Debug Test Orb"
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	spawner.orb_data_array = [orb_data]

	return spawner


func _create_spawner_with_mixed_pool() -> OrbSpawner:
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")

	# Add OrbProps
	var props := OrbProps.new()
	props.Type = Enums.OrbType.BLUE
	spawner.orb_props = [props]

	# Add OrbData
	var orb_data := OrbData.new()
	orb_data.display_name = "Mixed Test Orb"
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()
	spawner.orb_data_array = [orb_data]

	return spawner


func _create_test_texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	return texture


#endregion
