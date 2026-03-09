class_name PlayerPhysics
## Static class for player physics calculations.
## All functions are pure (no side effects) and work with primitive values.

## Checks if coyote time is still available.
## Returns true if current_time is within the timeout window after leaving ground.
static func can_coyote(time_left_ground: int, current_time: int, timeout_ms: float) -> bool:
	return current_time < time_left_ground + int(timeout_ms)


## Checks if a buffered jump is available.
## Returns true if current_time is within the timeout window after jump was pressed.
static func has_buffered_jump(time_pressed: int, current_time: int, timeout_ms: float) -> bool:
	return current_time < time_pressed + int(timeout_ms)


## Calculates vertical velocity based on gravity and ground state.
## When grounded and moving down/neutral: applies grounding force.
## When in air: applies gravity toward max_fall_speed.
## When ended jump early and moving up: applies modified (stronger) gravity.
static func calculate_gravity(
	current_velocity_y: float,
	is_grounded: bool,
	ended_jump_early: bool,
	config: PlayerPhysicsConfig,
	delta: float
) -> float:
	if config == null:
		return current_velocity_y

	# Grounded state: apply small downward force to stay on ground
	if is_grounded and current_velocity_y >= 0:
		return config.grounding_force

	# In air: apply gravity
	var gravity := config.fall_acceleration

	# Early jump release: apply stronger gravity for shorter jump
	if ended_jump_early and current_velocity_y < 0:
		gravity *= config.early_jump_gravity_modifier

	return move_toward(current_velocity_y, config.max_fall_speed, gravity * delta)


## Calculates horizontal velocity based on input direction and current velocity.
## Handles acceleration, deceleration, and direction changes.
static func calculate_horizontal_velocity(
	current: float,
	direction: float,
	target_speed: float,
	config: PlayerPhysicsConfig,
	delta: float
) -> float:
	if config == null:
		return current

	if direction != 0.0:
		# Moving in a direction
		if abs(current) < config.move_speed:
			# Below normal speed: use initial acceleration (faster start)
			return move_toward(current, direction * target_speed, config.initial_acceleration * delta)
		else:
			# At or above normal speed
			if sign(current * direction) == -1:
				# Direction change: reset to 0 for snappy turn
				return 0.0
			# Same direction: use normal acceleration
			return move_toward(current, direction * target_speed, config.acceleration * delta)

	# No input: decelerate toward 0
	return move_toward(current, 0.0, config.deceleration * delta)
