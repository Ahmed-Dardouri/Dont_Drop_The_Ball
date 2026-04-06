extends GutTest
## Unit tests for ModeManager singleton
## Tests lifecycle, mode loading, and high score management
##
## Uses the autoload singleton directly since ModeManager is registered
## in project.godot. State is reset in before_each.

var _signal_mode_started: bool = false
var _signal_mode_id: int = -1
var _signal_mode_ended: bool = false
var _signal_ended_result: Dictionary = {}


func before_each() -> void:
	# Reset ModeManager state before each test
	ModeManager.current_mode = null
	ModeManager._high_scores.clear()

	# Reset signal trackers
	_signal_mode_started = false
	_signal_mode_id = -1
	_signal_mode_ended = false
	_signal_ended_result = {}

	# Connect signals
	ModeManager.mode_started.connect(_on_mode_started)
	ModeManager.mode_ended.connect(_on_mode_ended)


func after_each() -> void:
	# Disconnect signals
	if ModeManager.mode_started.is_connected(_on_mode_started):
		ModeManager.mode_started.disconnect(_on_mode_started)
	if ModeManager.mode_ended.is_connected(_on_mode_ended):
		ModeManager.mode_ended.disconnect(_on_mode_ended)


func _on_mode_started(mode_id: int) -> void:
	_signal_mode_started = true
	_signal_mode_id = mode_id


func _on_mode_ended(_mode_id: int, result: Dictionary) -> void:
	_signal_mode_ended = true
	_signal_ended_result = result


#region Initial State Tests

func test_mode_manager_initial_current_mode() -> void:
	assert_null(ModeManager.current_mode, "Initial current_mode should be null")


func test_mode_manager_initial_available_modes() -> void:
	# Manager should load modes from resources/modes/
	assert_true(ModeManager._available_modes.size() > 0, "Should have loaded available modes")


#endregion

#region Start Mode Tests

func test_mode_manager_start_mode() -> void:
	ModeManager.start_mode(Enums.PlayMode.ENDLESS)

	assert_true(_signal_mode_started, "mode_started signal should be emitted")
	assert_eq(_signal_mode_id, Enums.PlayMode.ENDLESS, "Signal should emit correct mode_id")
	assert_not_null(ModeManager.current_mode, "current_mode should be set")
	assert_eq(ModeManager.current_mode.mode_id, Enums.PlayMode.ENDLESS, "current_mode should have correct mode_id")


func test_mode_manager_start_invalid_mode() -> void:
	ModeManager.start_mode(999)

	assert_false(_signal_mode_started, "mode_started signal should NOT be emitted for invalid mode")
	assert_null(ModeManager.current_mode, "current_mode should remain null for invalid mode")


#endregion

#region End Mode Tests

func test_mode_manager_end_mode() -> void:
	ModeManager.start_mode(Enums.PlayMode.ENDLESS)
	ModeManager.end_mode({"win": false})

	assert_true(_signal_mode_ended, "mode_ended signal should be emitted")
	assert_eq(_signal_ended_result.get("win", null), false, "Signal should emit correct result")
	assert_null(ModeManager.current_mode, "current_mode should be null after end_mode")


#endregion

#region Get Mode Config Tests

func test_mode_manager_get_mode_config() -> void:
	var config: ModeConfig = ModeManager.get_mode_config(Enums.PlayMode.ENDLESS)

	assert_not_null(config, "Should return config for valid mode_id")
	assert_eq(config.mode_id, Enums.PlayMode.ENDLESS, "Config should have correct mode_id")


func test_mode_manager_get_mode_config_invalid() -> void:
	var config: ModeConfig = ModeManager.get_mode_config(999)

	assert_null(config, "Should return null for invalid mode_id")


#endregion

#region High Score Tests

func test_mode_manager_get_high_score_default() -> void:
	var score: int = ModeManager.get_high_score(Enums.PlayMode.ENDLESS)

	assert_eq(score, 0, "Default high score should be 0")


func test_mode_manager_set_and_get_high_score() -> void:
	ModeManager.set_high_score(Enums.PlayMode.ENDLESS, 500)

	var score: int = ModeManager.get_high_score(Enums.PlayMode.ENDLESS)
	assert_eq(score, 500, "Should return the set high score")


func test_mode_manager_high_scores_per_mode() -> void:
	ModeManager.set_high_score(Enums.PlayMode.ENDLESS, 100)
	ModeManager.set_high_score(2, 200)

	assert_eq(ModeManager.get_high_score(Enums.PlayMode.ENDLESS), 100, "Endless high score should be 100")
	assert_eq(ModeManager.get_high_score(2), 200, "Second mode high score should be 200")


#endregion

#region Get Current Metric Tests

func test_mode_manager_get_current_metric_no_mode() -> void:
	var metric: Dictionary = ModeManager.get_current_metric()

	assert_eq(metric.size(), 0, "Should return empty dict when no mode is active")


func test_mode_manager_get_current_metric_with_mode() -> void:
	ModeManager.start_mode(Enums.PlayMode.ENDLESS)

	var metric: Dictionary = ModeManager.get_current_metric()

	assert_true(metric.has("name"), "Metric should have 'name' key")
	assert_true(metric.has("value"), "Metric should have 'value' key")


#endregion


#region Starting Lives Tests

func test_mode_manager_initializes_starting_lives() -> void:
	# Reset permanent lives
	Variables.permanent_lives = 0

	# Get beginner config and ensure it has starting_lives
	var config: ModeConfig = ModeManager.get_mode_config(Enums.PlayMode.BEGINNER)
	config.starting_lives = 3

	ModeManager.start_mode(Enums.PlayMode.BEGINNER)

	assert_eq(Variables.permanent_lives, 3, "Should initialize permanent_lives to starting_lives value")


func test_mode_manager_zero_starting_lives() -> void:
	# Reset permanent lives
	Variables.permanent_lives = 0

	# Get endless config (should have 0 starting_lives by default)
	ModeManager.start_mode(Enums.PlayMode.ENDLESS)

	assert_eq(Variables.permanent_lives, 0, "Should not add lives when starting_lives is 0")


#endregion
