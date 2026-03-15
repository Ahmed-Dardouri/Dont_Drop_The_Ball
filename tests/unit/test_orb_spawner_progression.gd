extends GutTest
## Unit tests for OrbSpawner progression integration.
## Tests that the spawner correctly filters orbs based on score.


#region Orb Filtering Tests

func test_spawner_filters_orbs_by_score() -> void:
	ScoreManager.reset_score()
	var spawner := _create_spawner_with_progression()
	assert_not_null(spawner, "Spawner should be created")

	# At score 0, only Blue Orb should be available
	var available: Array[String] = spawner.get_available_orb_names()
	assert_eq(available.size(), 1, "Only 1 orb should be available at score 0")
	assert_true(available.has("Blue Orb"), "Blue Orb should be available at score 0")


func test_spawner_expands_pool_with_score() -> void:
	var spawner := _create_spawner_with_progression()
	assert_not_null(spawner, "Spawner should be created")

	# Set score to 25 (above Burst threshold of 20)
	ScoreManager.reset_score()
	ScoreManager.set_score(25)

	var available: Array[String] = spawner.get_available_orb_names()
	assert_eq(available.size(), 2, "2 orbs should be available at score 25")
	assert_true(available.has("Blue Orb"), "Blue Orb should be available at score 25")
	assert_true(available.has("Burst Orb"), "Burst Orb should be available at score 25")


func test_spawner_all_orbs_at_high_score() -> void:
	var spawner := _create_spawner_with_progression()
	assert_not_null(spawner, "Spawner should be created")

	# Set score to 2000 (above all thresholds)
	ScoreManager.reset_score()
	ScoreManager.set_score(2000)

	var available: Array[String] = spawner.get_available_orb_names()
	assert_eq(available.size(), 5, "All 5 orbs should be available at score 2000")


func test_spawner_no_progression_config_means_all_orbs() -> void:
	var spawner := _create_spawner_without_progression()
	assert_not_null(spawner, "Spawner should be created")

	ScoreManager.reset_score()

	var available: Array[String] = spawner.get_available_orb_names()
	assert_eq(available.size(), 5, "All orbs should be available when no progression config")


#endregion

#region Life Orb Exclusion Tests

func test_life_orb_not_in_available_orbs() -> void:
	var spawner := _create_spawner_with_progression()
	assert_not_null(spawner, "Spawner should be created")

	# Even at high score, Life Orb should not be in available orbs
	ScoreManager.set_score(10000)

	var available: Array[String] = spawner.get_available_orb_names()
	assert_false(available.has("Life Orb"), "Life Orb should NOT be in available orbs from progression")


#endregion

#region Helper Methods

func _create_spawner_with_progression() -> OrbSpawner:
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")

	# Create orb data array
	var blue := _create_orb_data("Blue Orb")
	var burst := _create_orb_data("Burst Orb")
	var vortex := _create_orb_data("Vortex Orb")
	var horizontal := _create_orb_data("Horizontal Wave Orb")
	var speedup := _create_orb_data("Spawn Speedup Orb")

	spawner.orb_data_array = [burst, blue, horizontal, vortex, speedup]

	# Create progression config
	var config := ProgressionConfig.new()
	config.orb_unlock_thresholds = {
		"Blue Orb": 0,
		"Burst Orb": 20,
		"Vortex Orb": 100,
		"Horizontal Wave Orb": 500,
		"Spawn Speedup Orb": 1500,
	}
	config.base_spawn_interval = 2.5
	config.min_spawn_interval = 0.8
	config.max_progression_score = 3000.0
	config.progression_exponent = 0.7
	spawner.progression_config = config

	# Set life orb data (but it shouldn't appear in progression)
	spawner.life_orb_data = _create_orb_data("Life Orb")

	return spawner


func _create_spawner_without_progression() -> OrbSpawner:
	var spawner := OrbSpawner.new()
	spawner.generic_orb_scene = load("res://scenes/generic_orb.tscn")

	var blue := _create_orb_data("Blue Orb")
	var burst := _create_orb_data("Burst Orb")
	var vortex := _create_orb_data("Vortex Orb")
	var horizontal := _create_orb_data("Horizontal Wave Orb")
	var speedup := _create_orb_data("Spawn Speedup Orb")

	spawner.orb_data_array = [burst, blue, horizontal, vortex, speedup]

	# No progression config - all orbs should be available
	spawner.progression_config = null

	return spawner


func _create_orb_data(display_name: String) -> OrbData:
	var data := OrbData.new()
	data.display_name = display_name
	data.collision_radius = 32.0
	data.texture = _create_test_texture()
	data.spawn_weight = 1.0
	return data


func _create_test_texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	return texture


#endregion
