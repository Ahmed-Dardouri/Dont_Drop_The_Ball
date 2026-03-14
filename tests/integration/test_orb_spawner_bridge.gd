extends GutTest
## Integration tests for the OrbSpawner bridge to OrbData system
## Tests the complete flow from spawner selection to orb collection


var _score: int = 0


func before_each() -> void:
	_score = 0
	PauseEvent.state = false
	# Reset ScoreManager for each test
	ScoreManager.reset_score()
	ComboManager.reset_combo()


func after_each() -> void:
	PauseEvent.state = false


func _on_score_changed(new_score: int) -> void:
	_score = new_score


#region OrbData Path Integration

func test_spawner_creates_orb_data_orb() -> void:
	"""Verify that the OrbData path works via OrbAdapter end-to-end."""
	var spawner := _create_spawner_with_inline_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_orb()

	assert_not_null(result, "Spawner should create an orb from OrbData")
	assert_true(result is GenericOrb, "Result should be a GenericOrb")

	var orb: GenericOrb = result as GenericOrb
	assert_not_null(orb.get_orb_data(), "Orb should have OrbData set")
	assert_eq(orb.get_orb_data().display_name, "Integration Test Orb", "Should have correct display name")

	result.queue_free()
	spawner.queue_free()


func test_orb_data_orb_has_correct_properties() -> void:
	"""Verify that an orb created from OrbData has all correct properties."""
	var spawner := _create_spawner_with_inline_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_orb()
	add_child(result)
	await get_tree().process_frame

	var orb: GenericOrb = result as GenericOrb
	var data: OrbData = orb.get_orb_data()

	assert_eq(data.display_name, "Integration Test Orb", "Display name should match")
	assert_eq(data.base_score, 5, "Base score should match")
	assert_eq(data.collision_radius, 32.0, "Collision radius should match")
	assert_true(orb.is_in_group("orbs"), "Orb should be in 'orbs' group")

	result.queue_free()
	spawner.queue_free()


#endregion

#region Debug Force Spawn Integration

func test_debug_force_selects_correct_orb() -> void:
	"""Verify that debug_force_orb_type correctly selects the matching orb."""
	var spawner := _create_spawner_with_inline_orb_data()
	spawner.debug_force_orb_type = "Integration Test Orb"
	add_child(spawner)

	# Spawn multiple times - should always get "Integration Test Orb"
	for i in range(10):
		var result: Node = spawner._spawn_orb()
		assert_not_null(result, "Should always return an orb with debug force")

		var orb: GenericOrb = result as GenericOrb
		assert_eq(orb.get_orb_data().display_name, "Integration Test Orb", "Should always be Integration Test Orb")
		result.queue_free()

	spawner.queue_free()


#endregion

#region Collection Integration

func test_orb_data_orb_collectible() -> void:
	"""Verify that an orb created from OrbData can be collected and awards score."""
	ScoreManager.score_changed.connect(_on_score_changed)

	var spawner := _create_spawner_with_inline_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_orb()
	add_child(result)
	await get_tree().process_frame

	var orb: GenericOrb = result as GenericOrb
	assert_not_null(orb.get_orb_data(), "Orb should have OrbData")

	# Simulate collection
	orb.on_orb_collected()
	await get_tree().process_frame

	# Score should be awarded by ScoreBehavior (base_score * multiplier)
	assert_gt(_score, 0, "Score should be awarded when orb is collected")

	ScoreManager.score_changed.disconnect(_on_score_changed)
	spawner.queue_free()


func test_orb_data_orb_collection_fires_score_event() -> void:
	"""Verify that collecting an OrbData orb adds to ScoreManager."""
	ScoreManager.score_changed.connect(_on_score_changed)

	var spawner := _create_spawner_with_inline_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_orb()
	add_child(result)
	await get_tree().process_frame

	var orb: GenericOrb = result as GenericOrb

	# Collect the orb
	orb.on_orb_collected()
	await get_tree().process_frame

	# Test orb has base_score of 5, so we should get 5 + 1 combo = 6 points
	assert_eq(_score, 6, "Should award 5 points + 1 combo for Test Orb collection")

	ScoreManager.score_changed.disconnect(_on_score_changed)
	spawner.queue_free()


func test_orb_data_orb_queue_free_on_collection() -> void:
	"""Verify that collecting an OrbData orb properly frees it."""
	var spawner := _create_spawner_with_inline_orb_data()
	add_child(spawner)

	var result: Node = spawner._spawn_orb()
	add_child(result)
	await get_tree().process_frame

	var orb: GenericOrb = result as GenericOrb

	# Collect the orb
	orb.on_orb_collected()

	# Check immediately before the node is freed
	assert_true(orb.is_queued_for_deletion(), "Orb should be queued for deletion after collection")

	spawner.queue_free()


#endregion

#region Real Resource Tests

func test_real_test_orb_resource_loads() -> void:
	"""Verify that the real test_orb.tres resource can be loaded."""
	var resource: Resource = load("res://resources/orbs/test_orb.tres")
	assert_not_null(resource, "test_orb.tres should load successfully")

	# Cast to OrbData for property access
	var test_orb: OrbData = resource as OrbData
	assert_not_null(test_orb, "Resource should be castable to OrbData")
	assert_eq(test_orb.display_name, "Test Orb", "Should have correct display name")
	assert_eq(test_orb.base_score, 5, "Should have base_score of 5")
	assert_not_null(test_orb.texture, "Should have texture set")
	assert_eq(test_orb.behaviors.size(), 1, "Should have one behavior")


func test_real_test_orb_in_spawner() -> void:
	"""Verify that the real test_orb.tres works in a spawner."""
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")

	# Load and cast the resource
	var resource: Resource = load("res://resources/orbs/test_orb.tres")
	var test_orb: OrbData = resource as OrbData

	# Build array with explicit type
	var data_array: Array[OrbData] = []
	data_array.append(test_orb)
	spawner.orb_data_array = data_array
	spawner.debug_force_orb_type = "Test Orb"

	add_child(spawner)

	var result: Node = spawner._spawn_orb()
	assert_not_null(result, "Spawner should create an orb from test_orb.tres")

	var orb: GenericOrb = result as GenericOrb
	assert_eq(orb.get_orb_data().display_name, "Test Orb", "Should be the Test Orb from .tres file")

	result.queue_free()
	spawner.queue_free()


func test_migrated_basic_orbs_load() -> void:
	"""Verify that the migrated blue, red, and half_solid orb resources load."""
	var blue: Resource = load("res://resources/orbs/blue_orb.tres")
	var red: Resource = load("res://resources/orbs/red_orb.tres")
	var half_solid: Resource = load("res://resources/orbs/half_solid_orb.tres")

	assert_not_null(blue, "blue_orb.tres should load")
	assert_not_null(red, "red_orb.tres should load")
	assert_not_null(half_solid, "half_solid_orb.tres should load")

	var blue_data: OrbData = blue as OrbData
	var red_data: OrbData = red as OrbData
	var half_data: OrbData = half_solid as OrbData

	assert_eq(blue_data.display_name, "Blue Orb", "Blue orb should have correct name")
	assert_eq(blue_data.base_score, 2, "Blue orb should have score of 2")

	assert_eq(red_data.display_name, "Red Orb", "Red orb should have correct name")
	assert_eq(red_data.base_score, 3, "Red orb should have score of 3")

	assert_eq(half_data.display_name, "Half Solid Orb", "Half solid orb should have correct name")
	assert_eq(half_data.base_score, 8, "Half solid orb should have score of 8")
	assert_true(half_data.is_half_solid, "Half solid orb should have is_half_solid=true")


#endregion

#region Helper Methods

func _create_test_texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	return texture


func _create_inline_orb_data() -> OrbData:
	var orb_data := OrbData.new()
	orb_data.display_name = "Integration Test Orb"
	orb_data.texture = _create_test_texture()
	orb_data.scale = Vector2.ONE
	orb_data.base_score = 5
	orb_data.lifespan = 30.0
	orb_data.rarity = Enums.OrbRarity.COMMON
	orb_data.collision_radius = 32.0
	orb_data.is_half_solid = false

	# Create ScoreBehavior inline
	var score_behavior := ScoreBehavior.new()
	score_behavior.base_score = 5
	orb_data.behaviors = [score_behavior]

	return orb_data


func _create_spawner_with_inline_orb_data() -> OrbSpawner:
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")
	spawner.orb_data_array = [_create_inline_orb_data()]
	return spawner


#endregion
