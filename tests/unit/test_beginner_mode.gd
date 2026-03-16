extends GutTest
## Unit tests for BeginnerMode implementation.
## Tests lifecycle hooks and default beginner behavior.


func before_each() -> void:
	ScoreManager.reset_score()


#region BeginnerMode - Lifecycle Tests

func test_beginner_mode_extends_mode_base() -> void:
	var mode := BeginnerMode.new()
	assert_true(mode is ModeBase, "BeginnerMode should extend ModeBase")


func test_beginner_mode_has_on_start_hook() -> void:
	var mode := BeginnerMode.new()
	# Should not crash - method exists
	mode._on_start()
	assert_true(true, "_on_start method should exist")


func test_beginner_mode_has_on_process_hook() -> void:
	var mode := BeginnerMode.new()
	# Should not crash - method exists
	mode._on_process(0.016)
	assert_true(true, "_on_process method should exist")


func test_beginner_mode_has_on_orb_collected_hook() -> void:
	var mode := BeginnerMode.new()
	# Should not crash - method exists
	var result := mode._on_orb_collected(null, 10)
	assert_eq(result, 10, "_on_orb_collected should return base_score for beginner mode")


func test_beginner_mode_has_check_win_hook() -> void:
	var mode := BeginnerMode.new()
	var result := mode._check_win()
	assert_false(result, "_check_win should exist and return false for beginner mode")


func test_beginner_mode_has_check_lose_hook() -> void:
	var mode := BeginnerMode.new()
	var result := mode._check_lose()
	assert_false(result, "_check_lose should exist and return false for beginner mode")


func test_beginner_mode_has_on_end_hook() -> void:
	var mode := BeginnerMode.new()
	# Should not crash - method exists
	mode._on_end()
	assert_true(true, "_on_end method should exist")


func test_beginner_mode_has_get_metric_hook() -> void:
	var mode := BeginnerMode.new()
	var result := mode._get_metric()
	assert_true(result.has("name"), "_get_metric should return dict with 'name' key")
	assert_true(result.has("value"), "_get_metric should return dict with 'value' key")


func test_beginner_mode_has_get_final_score_hook() -> void:
	var mode := BeginnerMode.new()
	var result := mode._get_final_score()
	assert_true(result >= 0, "_get_final_score should return non-negative int")


func test_beginner_mode_has_config_property() -> void:
	var mode := BeginnerMode.new()
	assert_true("config" in mode, "BeginnerMode should have config property")


#endregion

#region BeginnerMode - Orb Collection Tests

func test_beginner_mode_on_orb_collected_passthrough() -> void:
	var mode := BeginnerMode.new()
	var result := mode._on_orb_collected(null, 10)
	assert_eq(result, 10, "BeginnerMode should pass through base_score unchanged")


func test_beginner_mode_on_orb_collected_zero_score() -> void:
	var mode := BeginnerMode.new()
	var result := mode._on_orb_collected(null, 0)
	assert_eq(result, 0, "BeginnerMode should pass through zero score")


func test_beginner_mode_on_orb_collected_large_score() -> void:
	var mode := BeginnerMode.new()
	var result := mode._on_orb_collected(null, 1000)
	assert_eq(result, 1000, "BeginnerMode should pass through large scores unchanged")


#endregion

#region BeginnerMode - Metric Tests

func test_beginner_mode_get_metric_returns_score_name() -> void:
	var mode := BeginnerMode.new()
	var result := mode._get_metric()
	assert_eq(result["name"], "score", "BeginnerMode metric name should be 'score'")


func test_beginner_mode_get_metric_returns_score_value() -> void:
	var mode := BeginnerMode.new()
	var result := mode._get_metric()
	assert_eq(result["value"], 0, "BeginnerMode metric value should start at 0")


func test_beginner_mode_get_final_score_returns_score() -> void:
	var mode := BeginnerMode.new()
	var result := mode._get_final_score()
	assert_eq(result, 0, "BeginnerMode final score should start at 0")


#endregion

#region BeginnerMode - Config Integration

func test_beginner_mode_can_hold_config() -> void:
	var mode := BeginnerMode.new()
	var config := ModeConfig.new()
	config.mode_id = "beginner"
	config.display_name = "Beginner"
	mode.config = config
	assert_eq(mode.config.mode_id, "beginner", "BeginnerMode should hold config reference")


#endregion

#region ModeManager Integration

func test_mode_manager_can_instantiate_beginner_mode() -> void:
	# Start beginner mode via ModeManager
	ModeManager.start_mode("beginner")

	# Verify mode implementation is a BeginnerMode instance
	var impl := ModeManager.get_mode_implementation()
	assert_not_null(impl, "ModeManager should have a mode implementation after start_mode")
	assert_true(impl is BeginnerMode, "ModeManager._mode_impl should be a BeginnerMode instance")

	# Clean up
	ModeManager.end_mode({"win": false})


func test_mode_manager_beginner_mode_has_config() -> void:
	ModeManager.start_mode("beginner")
	var impl := ModeManager.get_mode_implementation()
	assert_not_null(impl.config, "BeginnerMode instance should have config set")
	assert_eq(impl.config.mode_id, "beginner", "Config should be the beginner mode config")
	ModeManager.end_mode({"win": false})


#endregion
