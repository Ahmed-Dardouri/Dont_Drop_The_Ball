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


#region Easy Mode Assist Features Tests

func test_get_ball_gravity_scale_returns_zero_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_gravity_scale()
	assert_eq(result, 0.0, "Should return 0.0 when no mode is active")


func test_get_ball_gravity_scale_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.ball_gravity_scale = 0.35

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_gravity_scale()
	assert_eq(result, 0.35, "Should return mode-specific ball_gravity_scale")


func test_get_ball_scale_returns_zero_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_scale()
	assert_eq(result, 0.0, "Should return 0.0 when no mode is active")


func test_get_ball_scale_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.ball_scale = 1.3

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_scale()
	assert_eq(result, 1.3, "Should return mode-specific ball_scale")


func test_get_orb_scale_returns_zero_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_orb_scale()
	assert_eq(result, 0.0, "Should return 0.0 when no mode is active")


func test_get_orb_scale_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.orb_scale = 1.3

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_orb_scale()
	assert_eq(result, 1.3, "Should return mode-specific orb_scale")


func test_get_starting_lives_returns_zero_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: int = GameRules.get_starting_lives()
	assert_eq(result, 0, "Should return 0 when no mode is active")


func test_get_starting_lives_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.starting_lives = 3

	ModeManager.start_mode("beginner")
	var result: int = GameRules.get_starting_lives()
	assert_eq(result, 3, "Should return mode-specific starting_lives")


func test_get_permanent_life_pickups_returns_false_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: bool = GameRules.get_permanent_life_pickups()
	assert_false(result, "Should return false when no mode is active")


func test_get_permanent_life_pickups_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.permanent_life_pickups = true

	ModeManager.start_mode("beginner")
	var result: bool = GameRules.get_permanent_life_pickups()
	assert_true(result, "Should return mode-specific permanent_life_pickups")


func test_get_ball_slowdown_on_orb_returns_zero_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_slowdown_on_orb()
	assert_eq(result, 0.0, "Should return 0.0 when no mode is active")


func test_get_ball_slowdown_on_orb_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.ball_slowdown_on_orb = 0.7

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_slowdown_on_orb()
	assert_eq(result, 0.7, "Should return mode-specific ball_slowdown_on_orb")


func test_get_ball_slowdown_duration_returns_default_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: float = GameRules.get_ball_slowdown_duration()
	assert_eq(result, 0.5, "Should return default 0.5 when no mode is active")


func test_get_ball_slowdown_duration_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.ball_slowdown_duration = 1.0

	ModeManager.start_mode("beginner")
	var result: float = GameRules.get_ball_slowdown_duration()
	assert_eq(result, 1.0, "Should return mode-specific ball_slowdown_duration")


func test_get_show_landing_marker_returns_false_when_no_mode() -> void:
	ModeManager.current_mode = null
	var result: bool = GameRules.get_show_landing_marker()
	assert_false(result, "Should return false when no mode is active")


func test_get_show_landing_marker_returns_mode_value() -> void:
	var config: ModeConfig = ModeManager.get_mode_config("beginner")
	config.show_landing_marker = true

	ModeManager.start_mode("beginner")
	var result: bool = GameRules.get_show_landing_marker()
	assert_true(result, "Should return mode-specific show_landing_marker")


#endregion
