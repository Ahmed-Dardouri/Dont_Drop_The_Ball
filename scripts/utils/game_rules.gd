class_name GameRules
## Static utility for accessing mode-specific game settings.
## Provides a centralized way to get tuning values that can vary by mode.
## Falls back to global defaults (Constants) when no mode is active or mode doesn't override.

## Default background color (dark gray)
const DEFAULT_BACKGROUND_COLOR: Color = Color(0.158, 0.158, 0.158, 1.0)

#region Ball Physics

## Get the ball max speed for the current mode.
## Returns mode-specific value if set, otherwise falls back to Constants.
static func get_ball_max_speed() -> float:
	var config: BallPhysicsConfig = _get_ball_physics_config()
	if config != null:
		return config.max_speed
	return Constants.ball_max_speed


## Get the ball fall speed for the current mode.
## Returns mode-specific value if set, otherwise falls back to Constants.
static func get_ball_fall_speed() -> float:
	var config: BallPhysicsConfig = _get_ball_physics_config()
	if config != null:
		return config.max_fall_speed
	return Constants.ball_fall_speed


## Get the ball air friction for the current mode.
## Returns mode-specific value if set, otherwise falls back to Constants.
static func get_ball_air_friction() -> float:
	var config: BallPhysicsConfig = _get_ball_physics_config()
	if config != null:
		return config.air_friction
	return float(Constants.ball_air_friction)


## Get the current ball physics config from the active mode, or null.
static func _get_ball_physics_config() -> BallPhysicsConfig:
	if ModeManager == null or ModeManager.current_mode == null:
		return null
	return ModeManager.current_mode.ball_physics_config

#endregion

#region Progression

## Get the progression config for the current mode.
## Returns mode-specific config if set, otherwise null.
static func get_progression_config() -> ProgressionConfig:
	if ModeManager == null or ModeManager.current_mode == null:
		return null
	return ModeManager.current_mode.progression_config

#endregion

#region Visual Settings

## Get the background color for the current mode.
## Returns mode-specific color if set (non-zero), otherwise returns default dark gray.
static func get_background_color() -> Color:
	if ModeManager == null or ModeManager.current_mode == null:
		return DEFAULT_BACKGROUND_COLOR

	var mode_color: Color = ModeManager.current_mode.background_color
	# Check if a custom color was set (non-zero alpha or non-default values)
	if mode_color.a > 0 and (mode_color.r != 0 or mode_color.g != 0 or mode_color.b != 0):
		return mode_color

	return DEFAULT_BACKGROUND_COLOR

#endregion
