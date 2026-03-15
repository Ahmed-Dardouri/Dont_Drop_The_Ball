extends GutTest
## Unit tests for ModeBase abstract class and EndlessMode implementation
## Tests lifecycle hooks and default endless behavior


func before_each() -> void:
	ScoreManager.reset_score()


#region ModeBase Tests

func test_mode_base_extends_ref_counted() -> void:
	var mode := EndlessMode.new()
	assert_true(mode is RefCounted, "ModeBase should extend RefCounted")


func test_mode_base_has_on_start_hook() -> void:
	var mode := EndlessMode.new()
	# Should not crash - method exists
	mode._on_start()
	assert_true(true, "_on_start method should exist")


func test_mode_base_has_on_process_hook() -> void:
	var mode := EndlessMode.new()
	# Should not crash - method exists
	mode._on_process(0.016)
	assert_true(true, "_on_process method should exist")


func test_mode_base_has_on_orb_collected_hook() -> void:
	var mode := EndlessMode.new()
	# Should not crash - method exists
	var result := mode._on_orb_collected(null, 10)
	assert_eq(result, 10, "_on_orb_collected should return base_score for endless mode")


func test_mode_base_has_check_win_hook() -> void:
	var mode := EndlessMode.new()
	var result := mode._check_win()
	assert_false(result, "_check_win should exist and return false for endless mode")


func test_mode_base_has_check_lose_hook() -> void:
	var mode := EndlessMode.new()
	var result := mode._check_lose()
	assert_false(result, "_check_lose should exist and return false for endless mode")


func test_mode_base_has_on_end_hook() -> void:
	var mode := EndlessMode.new()
	# Should not crash - method exists
	mode._on_end()
	assert_true(true, "_on_end method should exist")


func test_mode_base_has_get_metric_hook() -> void:
	var mode := EndlessMode.new()
	var result := mode._get_metric()
	assert_true(result.has("name"), "_get_metric should return dict with 'name' key")
	assert_true(result.has("value"), "_get_metric should return dict with 'value' key")


func test_mode_base_has_get_final_score_hook() -> void:
	var mode := EndlessMode.new()
	var result := mode._get_final_score()
	assert_true(result >= 0, "_get_final_score should return non-negative int")


func test_mode_base_has_config_property() -> void:
	var mode := EndlessMode.new()
	assert_true("config" in mode, "ModeBase should have config property")


#endregion

#region EndlessMode - Check Win Tests

func test_endless_mode_check_win_returns_false() -> void:
	var mode := EndlessMode.new()
	assert_false(mode._check_win(), "EndlessMode should never have a win condition")


func test_endless_mode_check_win_returns_false_after_start() -> void:
	var mode := EndlessMode.new()
	mode._on_start()
	assert_false(mode._check_win(), "EndlessMode._check_win should still return false after start")


#endregion

#region EndlessMode - Check Lose Tests

func test_endless_mode_check_lose_returns_false() -> void:
	var mode := EndlessMode.new()
	assert_false(mode._check_lose(), "EndlessMode._check_lose returns false (game over handled by GameOverEvent)")


#endregion

#region EndlessMode - Orb Collection Tests

func test_endless_mode_on_orb_collected_passthrough() -> void:
	var mode := EndlessMode.new()
	var result := mode._on_orb_collected(null, 10)
	assert_eq(result, 10, "EndlessMode should pass through base_score unchanged")


func test_endless_mode_on_orb_collected_zero_score() -> void:
	var mode := EndlessMode.new()
	var result := mode._on_orb_collected(null, 0)
	assert_eq(result, 0, "EndlessMode should pass through zero score")


func test_endless_mode_on_orb_collected_large_score() -> void:
	var mode := EndlessMode.new()
	var result := mode._on_orb_collected(null, 1000)
	assert_eq(result, 1000, "EndlessMode should pass through large scores unchanged")


#endregion

#region EndlessMode - Metric Tests

func test_endless_mode_get_metric_returns_score_name() -> void:
	var mode := EndlessMode.new()
	var result := mode._get_metric()
	assert_eq(result["name"], "score", "EndlessMode metric name should be 'score'")


func test_endless_mode_get_metric_returns_score_value() -> void:
	var mode := EndlessMode.new()
	var result := mode._get_metric()
	assert_eq(result["value"], 0, "EndlessMode metric value should start at 0")


func test_endless_mode_get_final_score_returns_score() -> void:
	var mode := EndlessMode.new()
	var result := mode._get_final_score()
	assert_eq(result, 0, "EndlessMode final score should start at 0")


#endregion

#region EndlessMode - Config Integration

func test_endless_mode_can_hold_config() -> void:
	var mode := EndlessMode.new()
	var config := ModeConfig.new()
	config.mode_id = "endless"
	config.display_name = "Endless"
	mode.config = config
	assert_eq(mode.config.mode_id, "endless", "EndlessMode should hold config reference")


#endregion

#region ModeManager Integration

func test_mode_manager_can_instantiate_endless_mode() -> void:
	# Start endless mode via ModeManager
	ModeManager.start_mode("endless")

	# Verify mode implementation is an EndlessMode instance
	var impl := ModeManager.get_mode_implementation()
	assert_not_null(impl, "ModeManager should have a mode implementation after start_mode")
	assert_true(impl is EndlessMode, "ModeManager._mode_impl should be an EndlessMode instance")

	# Clean up
	ModeManager.end_mode({"win": false})


func test_mode_manager_endless_mode_has_config() -> void:
	ModeManager.start_mode("endless")
	var impl := ModeManager.get_mode_implementation()
	assert_not_null(impl.config, "EndlessMode instance should have config set")
	assert_eq(impl.config.mode_id, "endless", "Config should be the endless mode config")
	ModeManager.end_mode({"win": false})


#endregion
