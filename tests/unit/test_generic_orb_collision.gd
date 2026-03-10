extends GutTest
## Unit tests for GenericOrb OrbData collision support (F1 Fix)
## Tests that GenericOrb can accept OrbData and configure collision


#region set_orb_data Tests

func test_set_orb_data_stores_reference() -> void:
	var orb: GenericOrb = await _create_generic_orb_instance()
	var orb_data := OrbData.new()
	orb_data.display_name = "Test Orb"
	orb_data.base_score = 10

	orb.set_orb_data(orb_data)
	var retrieved: OrbData = orb.get_orb_data()

	assert_eq(retrieved, orb_data, "get_orb_data() should return the same OrbData reference")
	assert_eq(retrieved.display_name, "Test Orb", "OrbData should retain its properties")
	orb.queue_free()


func test_set_orb_data_returns_orb_data() -> void:
	var orb: GenericOrb = await _create_generic_orb_instance()
	var orb_data := OrbData.new()

	assert_eq(orb.get_orb_data(), null, "get_orb_data() should return null before set_orb_data()")

	orb.set_orb_data(orb_data)
	assert_not_null(orb.get_orb_data(), "get_orb_data() should return OrbData after set_orb_data()")
	orb.queue_free()


#endregion

#region Collision Configuration Tests

func test_set_orb_data_creates_circle_shape() -> void:
	var orb: GenericOrb = await _create_generic_orb_with_data()
	var shape: CollisionShape2D = orb.get_collision_shape()

	assert_not_null(shape, "Collision shape should exist")
	assert_true(shape.shape is CircleShape2D, "Collision shape should be CircleShape2D")
	orb.queue_free()


func test_set_orb_data_uses_collision_radius() -> void:
	var orb_data := OrbData.new()
	orb_data.collision_radius = 50.0
	orb_data.texture = _create_test_texture()

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)
	var shape: CollisionShape2D = orb.get_collision_shape()
	var circle: CircleShape2D = shape.shape as CircleShape2D

	assert_eq(circle.radius, 50.0, "Collision shape radius should match OrbData.collision_radius")
	orb.queue_free()


func test_set_orb_data_enables_monitoring() -> void:
	var orb: GenericOrb = await _create_generic_orb_with_data()
	var area: Area2D = orb.get_data_orb_area()

	assert_not_null(area, "DataOrbArea should exist")
	assert_true(area.monitoring, "Area2D monitoring should be enabled after set_orb_data()")
	orb.queue_free()


#endregion

#region Visual Sprite Tests

func test_set_orb_data_creates_sprite() -> void:
	var orb: GenericOrb = await _create_generic_orb_with_data()
	var sprite: Sprite2D = orb.get_visual_sprite()

	assert_not_null(sprite, "Visual sprite should be created after set_orb_data()")
	orb.queue_free()


func test_set_orb_data_sprite_has_texture() -> void:
	var texture: Texture2D = _create_test_texture()
	var orb_data := OrbData.new()
	orb_data.texture = texture

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)
	var sprite: Sprite2D = orb.get_visual_sprite()

	assert_eq(sprite.texture, texture, "Sprite should use OrbData.texture")
	orb.queue_free()


func test_set_orb_data_applies_scale() -> void:
	var orb_data := OrbData.new()
	orb_data.scale = Vector2(2.0, 2.0)
	orb_data.texture = _create_test_texture()

	var orb: GenericOrb = await _create_generic_orb_with_data(orb_data)
	var sprite: Sprite2D = orb.get_visual_sprite()

	assert_eq(sprite.scale, Vector2(2.0, 2.0), "Sprite should use OrbData.scale")
	orb.queue_free()


#endregion

#region Old Path Unaffected Tests

func test_orb_without_orb_data_has_null_getter() -> void:
	var orb: GenericOrb = await _create_generic_orb_instance()
	assert_eq(orb.get_orb_data(), null, "get_orb_data() should return null without set_orb_data()")
	orb.queue_free()


func test_data_orb_area_disabled_without_orb_data() -> void:
	var orb: GenericOrb = await _create_generic_orb_instance()

	var area: Area2D = orb.get_data_orb_area()
	if area != null:
		assert_false(area.monitoring, "DataOrbArea should be disabled when no OrbData is set")
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
