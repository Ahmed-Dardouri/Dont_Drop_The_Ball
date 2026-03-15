extends GutTest
## Unit tests for ProgressionConfig orb unlock and spawn rate progression.
## Tests score-based orb availability, threshold gating, and spawn rate scaling.


#region Orb Availability Tests

func test_blue_orb_available_at_score_zero() -> void:
	var config := _create_default_config()
	assert_true(config.is_orb_available("Blue Orb", 0), "Blue Orb should be available at score 0")


func test_burst_orb_not_available_below_threshold() -> void:
	var config := _create_default_config()
	assert_false(config.is_orb_available("Burst Orb", 0), "Burst Orb should NOT be available at score 0")
	assert_false(config.is_orb_available("Burst Orb", 19), "Burst Orb should NOT be available at score 19")


func test_burst_orb_available_at_threshold() -> void:
	var config := _create_default_config()
	assert_true(config.is_orb_available("Burst Orb", 20), "Burst Orb should be available at score 20")
	assert_true(config.is_orb_available("Burst Orb", 21), "Burst Orb should be available at score 21")


func test_vortex_orb_unlock_progression() -> void:
	var config := _create_default_config()
	assert_false(config.is_orb_available("Vortex Orb", 99), "Vortex Orb should NOT be available at score 99")
	assert_true(config.is_orb_available("Vortex Orb", 100), "Vortex Orb should be available at score 100")
	assert_true(config.is_orb_available("Vortex Orb", 150), "Vortex Orb should be available at score 150")


func test_horizontal_wave_orb_unlock_progression() -> void:
	var config := _create_default_config()
	assert_false(config.is_orb_available("Horizontal Wave Orb", 499), "Horizontal Wave Orb should NOT be available at score 499")
	assert_true(config.is_orb_available("Horizontal Wave Orb", 500), "Horizontal Wave Orb should be available at score 500")


func test_spawn_speedup_orb_unlock_progression() -> void:
	var config := _create_default_config()
	assert_false(config.is_orb_available("Spawn Speedup Orb", 1499), "Spawn Speedup Orb should NOT be available at score 1499")
	assert_true(config.is_orb_available("Spawn Speedup Orb", 1500), "Spawn Speedup Orb should be available at score 1500")


func test_unknown_orb_always_available() -> void:
	var config := _create_default_config()
	# Orbs not in thresholds dictionary default to threshold 0
	assert_true(config.is_orb_available("Unknown Orb Type", 0), "Unknown orb types should be available at score 0")


#endregion

#region Available Orbs List Tests

func test_get_available_orbs_at_score_zero() -> void:
	var config := _create_default_config()
	var available: Array[String] = config.get_available_orbs(0)
	assert_eq(available.size(), 1, "Only 1 orb should be available at score 0")
	assert_true(available.has("Blue Orb"), "Blue Orb should be in available list at score 0")


func test_get_available_orbs_expands_with_score() -> void:
	var config := _create_default_config()

	var at_zero: Array[String] = config.get_available_orbs(0)
	assert_eq(at_zero.size(), 1, "1 orb at score 0")

	var at_twenty: Array[String] = config.get_available_orbs(20)
	assert_eq(at_twenty.size(), 2, "2 orbs at score 20")
	assert_true(at_twenty.has("Blue Orb"), "Blue Orb should be available at score 20")
	assert_true(at_twenty.has("Burst Orb"), "Burst Orb should be available at score 20")

	var at_hundred: Array[String] = config.get_available_orbs(100)
	assert_eq(at_hundred.size(), 3, "3 orbs at score 100")

	var at_five_hundred: Array[String] = config.get_available_orbs(500)
	assert_eq(at_five_hundred.size(), 4, "4 orbs at score 500")

	var at_fifteen_hundred: Array[String] = config.get_available_orbs(1500)
	assert_eq(at_fifteen_hundred.size(), 5, "5 orbs at score 1500")


func test_all_orbs_available_at_high_score() -> void:
	var config := _create_default_config()
	var available: Array[String] = config.get_available_orbs(10000)
	assert_eq(available.size(), 5, "All 5 orbs should be available at score 10000")


#endregion

#region Spawn Rate Progression Tests

func test_spawn_interval_at_score_zero() -> void:
	var config := _create_default_config()
	var interval: float = config.get_spawn_interval_for_score(0)
	assert_eq(interval, 2.5, "Spawn interval should be base (2.5s) at score 0")


func test_spawn_interval_decreases_with_score() -> void:
	var config := _create_default_config()

	var at_zero: float = config.get_spawn_interval_for_score(0)
	var at_thousand: float = config.get_spawn_interval_for_score(1000)
	var at_max: float = config.get_spawn_interval_for_score(3000)

	assert_gt(at_zero, at_thousand, "Spawn interval should decrease as score increases")
	assert_gt(at_thousand, at_max, "Spawn interval should continue decreasing")


func test_spawn_interval_reaches_minimum() -> void:
	var config := _create_default_config()
	var interval: float = config.get_spawn_interval_for_score(3000)
	assert_almost_eq(interval, 0.8, 0.01, "Spawn interval should reach minimum at max progression score")


func test_spawn_interval_clamped_at_minimum() -> void:
	var config := _create_default_config()
	var at_max: float = config.get_spawn_interval_for_score(3000)
	var at_beyond: float = config.get_spawn_interval_for_score(10000)
	assert_eq(at_max, at_beyond, "Spawn interval should not go below minimum")


func test_spawn_interval_progression_is_smooth() -> void:
	var config := _create_default_config()

	var prev_interval: float = config.get_spawn_interval_for_score(0)
	for score: int in [500, 1000, 1500, 2000, 2500, 3000]:
		var current: float = config.get_spawn_interval_for_score(score)
		assert_lt(current, prev_interval, "Spawn interval should monotonically decrease")
		prev_interval = current


#endregion

#region Threshold Query Tests

func test_get_threshold_for_orb() -> void:
	var config := _create_default_config()
	assert_eq(config.get_threshold_for_orb("Blue Orb"), 0, "Blue Orb threshold should be 0")
	assert_eq(config.get_threshold_for_orb("Burst Orb"), 20, "Burst Orb threshold should be 20")
	assert_eq(config.get_threshold_for_orb("Vortex Orb"), 100, "Vortex Orb threshold should be 100")
	assert_eq(config.get_threshold_for_orb("Horizontal Wave Orb"), 500, "Horizontal Wave Orb threshold should be 500")
	assert_eq(config.get_threshold_for_orb("Spawn Speedup Orb"), 1500, "Spawn Speedup Orb threshold should be 1500")


func test_get_threshold_for_unknown_orb() -> void:
	var config := _create_default_config()
	assert_eq(config.get_threshold_for_orb("Unknown Orb"), 0, "Unknown orb threshold should default to 0")


#endregion

#region Life Orb Exclusion Tests

func test_life_orb_not_in_progression_thresholds() -> void:
	var config := _create_default_config()
	# Life Orb should not be in the unlock thresholds - it has its own timer
	assert_false(config.orb_unlock_thresholds.has("Life Orb"), "Life Orb should NOT be in unlock thresholds")


#endregion

#region Helper Methods

func _create_default_config() -> ProgressionConfig:
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
	return config


#endregion
