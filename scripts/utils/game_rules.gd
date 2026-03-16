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


## Get whether to show parallax background for the current mode.
static func get_show_parallax_background() -> bool:
	if ModeManager == null or ModeManager.current_mode == null:
		return true  # Default to showing parallax

	return ModeManager.current_mode.show_parallax_background

#endregion

#region Player Physics

## Get the player jump power for the current mode.
## Returns mode-specific value if set, otherwise falls back to Constants.
static func get_player_jump_power() -> int:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.jump_power
	return Constants.player_jump_power


## Get the player keyboard move power for the current mode.
static func get_player_keyboard_move_power() -> int:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.keyboard_move_power if config.keyboard_move_power != 0 else Constants.player_keyboard_move_power
	return Constants.player_keyboard_move_power


## Get the player initial move speed for the current mode.
static func get_player_initial_move_speed() -> int:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.move_speed
	return Constants.player_initial_move_speed


## Get the player acceleration for the current mode.
static func get_player_acceleration() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.acceleration
	return Constants.player_move_acceleration


## Get the player initial acceleration for the current mode.
static func get_player_initial_acceleration() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.initial_acceleration
	return Constants.player_initial_move_acceleration


## Get the player deceleration for the current mode.
static func get_player_deceleration() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.deceleration
	return Constants.player_move_deceleration


## Get the player coyote timeout for the current mode.
static func get_player_coyote_timeout() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.coyote_timeout
	return Constants.player_coyote_timeout


## Get the player jump buffer timeout for the current mode.
static func get_player_jump_buffer_timeout() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.jump_buffer_timeout
	return Constants.player_jump_buffer_timeout


## Get the player fall acceleration for the current mode.
static func get_player_fall_acceleration() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.fall_acceleration
	return Constants.player_fall_acceleration


## Get the player max fall speed for the current mode.
static func get_player_max_fall_speed() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.max_fall_speed
	return Constants.player_max_fall_speed


## Get the player grounding force for the current mode.
static func get_player_grounding_force() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.grounding_force
	return Constants.player_grounding_force


## Get the player early jump gravity modifier for the current mode.
static func get_player_early_jump_gravity_modifier() -> float:
	var config: PlayerPhysicsConfig = _get_player_physics_config()
	if config != null:
		return config.early_jump_gravity_modifier
	return Constants.player_Jump_ended_early_gravity_modifier


## Get the current player physics config from the active mode, or null.
static func _get_player_physics_config() -> PlayerPhysicsConfig:
	if ModeManager == null or ModeManager.current_mode == null:
		return null
	return ModeManager.current_mode.player_physics_config

#endregion
