extends GutTest
## Unit tests for OrbAdapter utility class
## Tests the bridge between OrbData and GenericOrb instantiation


#region create_orb_from_data Tests

func test_create_orb_from_data_returns_generic_orb() -> void:
	var orb_data := OrbData.new()
	orb_data.display_name = "Test Orb"
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()

	var scene: PackedScene = load("res://scenes/generic_orb.tscn")
	var orb: GenericOrb = OrbAdapter.create_orb_from_data(scene, orb_data)

	assert_not_null(orb, "create_orb_from_data() should return a GenericOrb")
	assert_true(orb is GenericOrb, "Returned object should be GenericOrb type")
	orb.queue_free()


func test_created_orb_has_orb_data_set() -> void:
	var orb_data := OrbData.new()
	orb_data.display_name = "Test Orb"
	orb_data.base_score = 25
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()

	var orb: GenericOrb = await _create_orb_from_adapter(orb_data)

	var retrieved: OrbData = orb.get_orb_data()
	assert_eq(retrieved, orb_data, "get_orb_data() should return the same OrbData")
	assert_eq(retrieved.display_name, "Test Orb", "OrbData properties should be preserved")
	assert_eq(retrieved.base_score, 25, "OrbData base_score should be preserved")
	orb.queue_free()


#endregion

#region Null Safety Tests

func test_null_scene_returns_null() -> void:
	var orb_data := OrbData.new()
	orb_data.display_name = "Test Orb"

	var orb: GenericOrb = OrbAdapter.create_orb_from_data(null, orb_data)

	assert_null(orb, "create_orb_from_data() should return null when scene is null")


func test_null_data_returns_null() -> void:
	var scene: PackedScene = load("res://scenes/generic_orb.tscn")

	var orb: GenericOrb = OrbAdapter.create_orb_from_data(scene, null)

	assert_null(orb, "create_orb_from_data() should return null when orb_data is null")


func test_both_null_returns_null() -> void:
	var orb: GenericOrb = OrbAdapter.create_orb_from_data(null, null)

	assert_null(orb, "create_orb_from_data() should return null when both args are null")


#endregion

#region Orbs Group Tests

func test_created_orb_in_orbs_group() -> void:
	var orb_data := OrbData.new()
	orb_data.display_name = "Test Orb"
	orb_data.collision_radius = 32.0
	orb_data.texture = _create_test_texture()

	var orb: GenericOrb = await _create_orb_from_adapter(orb_data)

	assert_true(orb.is_in_group("orbs"), "Created orb should be in 'orbs' group")
	orb.queue_free()


#endregion

#region Helper Methods

func _create_orb_from_adapter(orb_data: OrbData = null) -> GenericOrb:
	"""Create an orb via OrbAdapter and add it to the scene tree."""
	if orb_data == null:
		orb_data = OrbData.new()
		orb_data.collision_radius = 32.0
		orb_data.texture = _create_test_texture()

	var scene: PackedScene = load("res://scenes/generic_orb.tscn")
	var orb: GenericOrb = OrbAdapter.create_orb_from_data(scene, orb_data)
	add_child(orb)
	await get_tree().process_frame
	return orb


func _create_test_texture() -> Texture2D:
	"""Create a minimal test texture (1x1 white pixel)."""
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	return texture


#endregion
