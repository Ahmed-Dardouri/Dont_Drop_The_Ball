extends GutTest
## Unit tests for GameRules utility class.
## Tests mode-specific settings access with fallback behavior.


func before_each() -> void:
	# Reset ModeManager state
	ModeManager.current_mode = null
	ModeManager._mode_impl = null

	# Reset mode configs to clean state
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
		endless_config.background_color = Color(0, 0, 0, 0)

	if beginner_config != null:
		beginner_config.ball_physics_config = null
		beginner_config.progression_config = null
		beginner_config.background_color = Color(0, 0, 0, 0)


#region Background Color Tests

func test_get_background_color_returns_default_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: Color = GameRules.get_background_color()
	assert_eq(result, GameRules.DEFAULT_BACKGROUND_COLOR, "Should return default background color when no mode")


func test_get_background_color_returns_mode_color_when_set() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.background_color = Color(0.5, 0.5, 0.5, 1.0)

	ModeManager.start_mode("beginner")
	var result: Color = GameRules.get_background_color()
	assert_eq(result, Color(0.5, 0.5, 0.5, 1.0), "Should return mode-specific background color")


func test_get_background_color_returns_default_when_zero_color() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.background_color = Color(0, 0, 0, 0)  # Zero color means use default

	ModeManager.start_mode("beginner")
	var result: Color = GameRules.get_background_color()
	assert_eq(result, GameRules.DEFAULT_BACKGROUND_COLOR, "Should return default when mode color is zero")

	ModeManager.end_mode({"win": false})


#endregion


#region Default Fallback Tests

func test_get_ball_max_speed_returns_default_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_max_speed()
	assert_eq(result, Constants.ball_max_speed, "Should return Constants.ball_max_speed when no mode")


func test_get_ball_fall_speed_returns_default_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_fall_speed()
	assert_eq(result, Constants.ball_fall_speed, "Should return Constants.ball_fall_speed when no mode")


func test_get_ball_air_friction_returns_default_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_air_friction()
	assert_eq(result, float(Constants.ball_air_friction), "Should return Constants.ball_air_friction as float when no mode")


func test_get_progression_config_returns_null_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: ProgressionConfig = GameRules.get_progression_config()
	assert_null(result, "Should return null when no mode is active")


func test_get_progression_config_returns_null_when_mode_has_no_config() -> void:
	# Endless mode has null progression_config by default
	ModeManager.start_mode("endless")
	var result: ProgressionConfig = GameRules.get_progression_config()
	assert_null(result, "Should return null when mode's progression_config is null")


#endregion

#region Mode-Specific Value Tests

func test_get_ball_max_speed_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	var physics: BallPhysicsConfig = BallPhysicsConfig.new()
	physics.max_speed = 750.0
	config.ball_physics_config = physics

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_max_speed()
	assert_eq(result, 750.0, "Should return mode-specific max_speed")


func test_get_ball_fall_speed_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	var physics: BallPhysicsConfig = BallPhysicsConfig.new()
	physics.max_fall_speed = 400.0
	config.ball_physics_config = physics

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_fall_speed()
	assert_eq(result, 400.0, "Should return mode-specific max_fall_speed")


func test_get_ball_air_friction_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	var physics: BallPhysicsConfig = BallPhysicsConfig.new()
	physics.air_friction = 12.0
	config.ball_physics_config = physics

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_air_friction()
	assert_eq(result, 12.0, "Should return mode-specific air_friction")


func test_get_progression_config_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	var progression: ProgressionConfig = ProgressionConfig.new()
	config.progression_config = progression

	ModeManager.start_mode("beginner")
	var result: ProgressionConfig = GameRules.get_progression_config()
	assert_not_null(result, "Should return mode's progression config")
	assert_same(result, progression, "Should return the exact progression instance")


#endregion

#region Partial Override Tests

func test_partial_physics_override_uses_defaults_for_missing() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	var physics: BallPhysicsConfig = BallPhysicsConfig.new()
	# Only set max_speed, leave others at defaults
	physics.max_speed = 800.0
	physics.max_fall_speed = Constants.ball_fall_speed  # Same as default
	physics.air_friction = float(Constants.ball_air_friction)  # Same as default
	config.ball_physics_config = physics

	ModeManager.start_mode("beginner")

	# All values should come from the mode config
	assert_eq(GameRules.get_ball_max_speed(), 800.0, "Should use mode max_speed")
	assert_eq(GameRules.get_ball_fall_speed(), physics.max_fall_speed, "Should use mode max_fall_speed")
	assert_eq(GameRules.get_ball_air_friction(), physics.air_friction, "Should use mode air_friction")


#endregion

#region Mode Switching Tests

func test_game_rules_updates_on_mode_switch() -> void:
	# Set up endless with one config
	var endless_config: ModeConfig = ModeManager.get_mode_config("endless")
	var endless_physics: BallPhysicsConfig = BallPhysicsConfig.new()
	endless_physics.max_speed = 900.0
	endless_config.ball_physics_config = endless_physics

	# Set up beginner with different config
	var beginner_config: ModeConfig = ModeManager.get_mode_config("beginner")
	var beginner_physics: BallPhysicsConfig = BallPhysicsConfig.new()
	beginner_physics.max_speed = 600.0
	beginner_config.ball_physics_config = beginner_physics

	# Start endless
	ModeManager.start_mode("endless")
	assert_eq(GameRules.get_ball_max_speed(), 900.0, "Should use endless physics")

	# Switch to beginner
	ModeManager.end_mode({"win": false})
	ModeManager.start_mode("beginner")
	assert_eq(GameRules.get_ball_max_speed(), 600.0, "Should use beginner physics")


func test_game_rules_resets_on_mode_end() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	var physics: BallPhysicsConfig = BallPhysicsConfig.new()
	physics.max_speed = 500.0
	config.ball_physics_config = physics

	ModeManager.start_mode("beginner")
	assert_eq(GameRules.get_ball_max_speed(), 500.0, "Should use mode physics")

	ModeManager.end_mode({"win": false})
	assert_eq(GameRules.get_ball_max_speed(), Constants.ball_max_speed, "Should fall back to Constants")


#endregion
