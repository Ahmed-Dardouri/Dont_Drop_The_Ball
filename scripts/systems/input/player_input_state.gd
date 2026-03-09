class_name PlayerInputState
## Tracks and processes input state for player movement.
## Handles move direction, jump state, and timing for buffered jumps.

## Current movement direction (-1.0 = left, 0.0 = none, 1.0 = right)
var move_direction: float = 0.0

## Whether jump button is currently held
var jump_held: bool = false

## Whether jump was just pressed this frame
var jump_just_pressed: bool = false

## Timestamp of last jump press (for buffered jump calculation)
var last_jump_time: int = 0


## Process an input event and update state accordingly.
## Handles "Left", "Right", and "Jump" actions.
func process_input(event: InputEvent) -> void:
	# Handle movement direction
	if event.is_action_pressed("Left"):
		move_direction = -1.0
	elif event.is_action_released("Left"):
		if move_direction < 0:
			move_direction = 0.0

	if event.is_action_pressed("Right"):
		move_direction = 1.0
	elif event.is_action_released("Right"):
		if move_direction > 0:
			move_direction = 0.0

	# Handle jump
	if event.is_action_pressed("Jump"):
		jump_held = true
		jump_just_pressed = true
		last_jump_time = Time.get_ticks_msec()
	elif event.is_action_released("Jump"):
		jump_held = false


## Reset all state to defaults.
## Call this when starting a new game or resetting player state.
func reset() -> void:
	move_direction = 0.0
	jump_held = false
	jump_just_pressed = false
