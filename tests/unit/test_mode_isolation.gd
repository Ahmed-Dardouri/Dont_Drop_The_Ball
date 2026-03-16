extends GutTest
## Unit tests for mode isolation between EndlessMode and BeginnerMode.
## Verifies that modes are structurally separate and values don't leak.


func before_each() -> void:
	# Reset ModeManager state
	ModeManager.current_mode = null
	ModeManager._mode_impl = null

	# Reset mode configs to clean state (tests may modify them)
	_reset_mode_configs()


func after_each() -> void:
	# Clean up mode state
	if ModeManager.current_mode != null:
		ModeManager.end_mode({"win": false})

	# Reset configs for next test
	_reset_mode_configs()


func _reset_mode_configs() -> void:
	# Reset the mode configs to their default null state
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	if endless_config != null:
		endless_config.ball_physics_config = null
		endless_config.progression_config = null

	if beginner_config != null:
		beginner_config.ball_physics_config = null
		beginner_config.progression_config = null


#region Mode Config Separation Tests

func test_mode_configs_are_separate_resources() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	assert_not_null(endless_config, "Endless config should exist")
	assert_not_null(beginner_config, "Beginner config should exist")
	assert_not_same(endless_config, beginner_config, "Configs should be separate instances")


func test_mode_ids_are_different() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	assert_eq(endless_config.mode_id, "endless", "Endless mode_id should be 'endless'")
	assert_eq(beginner_config.mode_id, "beginner", "Beginner mode_id should be 'beginner'")


func test_mode_display_names_are_different() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	assert_eq(endless_config.display_name, "Endless", "Endless display_name should be 'Endless'")
	assert_eq(beginner_config.display_name, "Beginner", "Beginner display_name should be 'Beginner'")


#endregion

#region Mode Implementation Separation Tests

func test_beginner_mode_implementation_is_separate_class() -> void:
	ModeManager.start_mode("beginner")
	var impl: ModeBase = ModeManager.get_mode_implementation()

	assert_not_null(impl, "Beginner mode should have implementation")
	assert_true(impl is BeginnerMode, "Implementation should be BeginnerMode instance")
	assert_false(impl is EndlessMode, "BeginnerMode should not be EndlessMode")


func test_endless_mode_implementation_is_correct_class() -> void:
	ModeManager.start_mode("endless")
	var impl: ModeBase = ModeManager.get_mode_implementation()

	assert_not_null(impl, "Endless mode should have implementation")
	assert_true(impl is EndlessMode, "Implementation should be EndlessMode instance")


func test_both_modes_can_be_loaded() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	assert_not_null(endless_config.implementation, "Endless should have implementation script")
	assert_not_null(beginner_config.implementation, "Beginner should have implementation script")
	assert_not_same(endless_config.implementation, beginner_config.implementation, "Implementation scripts should be different")


#endregion

#region Ball Physics Isolation Tests

func test_mode_config_has_ball_physics_field() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("endless")
	assert_true("ball_physics_config" in config, "ModeConfig should have ball_physics_config field")


func test_ball_physics_configs_default_to_null() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	assert_null(endless_config.ball_physics_config, "Endless ball_physics_config should default to null")
	assert_null(beginner_config.ball_physics_config, "Beginner ball_physics_config should default to null")


func test_changing_beginner_ball_physics_does_not_affect_endless() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	# Set beginner mode's ball physics
	var custom_physics: BallPhysicsConfig = BallPhysicsConfig.new()
	custom_physics.max_speed = 500.0
	custom_physics.max_fall_speed = 300.0
	beginner_config.ball_physics_config = custom_physics

	# Endless should still be null
	assert_null(endless_config.ball_physics_config, "Endless ball_physics_config should still be null")
	assert_not_null(beginner_config.ball_physics_config, "Beginner ball_physics_config should be set")
	assert_eq(beginner_config.ball_physics_config.max_speed, 500.0, "Beginner max_speed should be 500")


#endregion

#region Progression Config Isolation Tests

func test_mode_config_has_progression_field() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("endless")
	assert_true("progression_config" in config, "ModeConfig should have progression_config field")


func test_progression_configs_default_to_null() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	assert_null(endless_config.progression_config, "Endless progression_config should default to null")
	assert_null(beginner_config.progression_config, "Beginner progression_config should default to null")


func test_changing_beginner_progression_does_not_affect_endless() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	# Set beginner mode's progression
	var custom_progression: ProgressionConfig = ProgressionConfig.new()
	custom_progression.base_spawn_interval = 5.0
	beginner_config.progression_config = custom_progression

	# Endless should still be null
	assert_null(endless_config.progression_config, "Endless progression_config should still be null")
	assert_not_null(beginner_config.progression_config, "Beginner progression_config should be set")
	assert_eq(beginner_config.progression_config.base_spawn_interval, 5.0, "Beginner base_spawn_interval should be 5.0")


#endregion

#region GameRules Tests

func test_game_rules_returns_defaults_when_no_mode_active() -> void:
	# Ensure no mode is active
	ModeManager.current_mode = null

	var max_speed: float = GameRules.get_ball_max_speed()
	var fall_speed: float = GameRules.get_ball_fall_speed()
	var air_friction: float = GameRules.get_ball_air_friction()

	# Should return Constants values
	assert_eq(max_speed, Constants.ball_max_speed, "Should return Constants.ball_max_speed")
	assert_eq(fall_speed, Constants.ball_fall_speed, "Should return Constants.ball_fall_speed")
	assert_eq(air_friction, float(Constants.ball_air_friction), "Should return Constants.ball_air_friction as float")


func test_game_rules_returns_mode_values_when_set() -> void:
	# Set up a mode with custom physics
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")
	var custom_physics: BallPhysicsConfig = BallPhysicsConfig.new()
	custom_physics.max_speed = 700.0
	custom_physics.max_fall_speed = 350.0
	custom_physics.air_friction = 5.0
	beginner_config.ball_physics_config = custom_physics

	# Start the mode
	ModeManager.start_mode("beginner")

	var max_speed: float = GameRules.get_ball_max_speed()
	var fall_speed: float = GameRules.get_ball_fall_speed()
	var air_friction: float = GameRules.get_ball_air_friction()

	assert_eq(max_speed, 700.0, "Should return mode-specific max_speed")
	assert_eq(fall_speed, 350.0, "Should return mode-specific max_fall_speed")
	assert_eq(air_friction, 5.0, "Should return mode-specific air_friction")


func test_game_rules_returns_null_progression_when_not_set() -> void:
	ModeManager.current_mode = null
	var progression: ProgressionConfig = GameRules.get_progression_config()
	assert_null(progression, "Should return null when no mode is active")


func test_game_rules_returns_mode_progression_when_set() -> void:
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")
	var custom_progression: ProgressionConfig = ProgressionConfig.new()
	beginner_config.progression_config = custom_progression

	ModeManager.start_mode("beginner")
	var progression: ProgressionConfig = GameRules.get_progression_config()

	assert_not_null(progression, "Should return mode's progression config")
	assert_same(progression, custom_progression, "Should return the exact progression instance")


#endregion

#region Mode Switching Isolation Tests

func test_switching_modes_updates_game_rules() -> void:
	# Set up both modes with different physics
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	var endless_physics: BallPhysicsConfig = BallPhysicsConfig.new()
	endless_physics.max_speed = 900.0
	endless_config.ball_physics_config = endless_physics

	var beginner_physics: BallPhysicsConfig = BallPhysicsConfig.new()
	beginner_physics.max_speed = 600.0
	beginner_config.ball_physics_config = beginner_physics

	# Start endless mode
	ModeManager.start_mode("endless")
	assert_eq(GameRules.get_ball_max_speed(), 900.0, "Endless mode should have 900 max_speed")

	# Switch to beginner mode
	ModeManager.end_mode({"win": false})
	ModeManager.start_mode("beginner")
	assert_eq(GameRules.get_ball_max_speed(), 600.0, "Beginner mode should have 600 max_speed")


func test_endless_mode_values_unchanged_after_beginner_modified() -> void:
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")

	# Store original endless values
	var original_endless_ball: BallPhysicsConfig = endless_config.ball_physics_config
	var original_endless_progression: ProgressionConfig = endless_config.progression_config

	# Modify beginner mode
	beginner_config.ball_physics_config = BallPhysicsConfig.new()
	beginner_config.ball_physics_config.max_speed = 100.0
	beginner_config.progression_config = ProgressionConfig.new()

	# Endless should be unchanged
	assert_same(endless_config.ball_physics_config, original_endless_ball, "Endless ball physics should be unchanged")
	assert_same(endless_config.progression_config, original_endless_progression, "Endless progression should be unchanged")


#endregion
