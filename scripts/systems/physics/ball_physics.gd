class_name BallPhysics
## Static class for ball physics calculations.
## All functions are pure (no side effects) and return new Vector2 values.

## Clamps the velocity magnitude to max_speed.
## Returns unchanged velocity if max_speed is 0 or negative.
static func clamp_max_speed(velocity: Vector2, max_speed: float) -> Vector2:
	if max_speed > 0.0:
		var speed := velocity.length()
		if speed > max_speed:
			return velocity.normalized() * max_speed
	return velocity


## Clamps the vertical (Y) component of velocity to max_fall_speed.
## Only affects downward (positive Y) velocity.
## Returns unchanged velocity if max_fall_speed is 0 or negative.
static func clamp_fall_speed(velocity: Vector2, max_fall_speed: float) -> Vector2:
	var result := velocity
	if max_fall_speed > 0.0 and result.y > max_fall_speed:
		result.y = max_fall_speed
	return result


## Applies air friction to horizontal (X) velocity.
## Friction is a value where 9 means 0.9% reduction per frame.
## Returns unchanged velocity if friction is 0 or negative.
static func apply_air_friction(velocity: Vector2, friction: float) -> Vector2:
	var result := velocity
	if friction > 0.0:
		result.x *= (1.0 - friction / 1000.0)
	return result


## Applies all physics processing to velocity using config values.
## Order: clamp_max_speed -> clamp_fall_speed -> apply_air_friction
## Returns unchanged velocity if config is null.
static func process_velocity(velocity: Vector2, config: BallPhysicsConfig) -> Vector2:
	if config == null:
		return velocity
	var result := clamp_max_speed(velocity, config.max_speed)
	result = clamp_fall_speed(result, config.max_fall_speed)
	result = apply_air_friction(result, config.air_friction)
	return result
