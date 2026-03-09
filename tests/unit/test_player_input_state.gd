extends GutTest
## Unit tests for PlayerInputState class

var _input_state: PlayerInputState

func before_each() -> void:
	_input_state = PlayerInputState.new()


#region Initial State tests

func test_initial_move_direction() -> void:
	assert_eq(_input_state.move_direction, 0.0, "Initial direction should be 0")


func test_initial_jump_held() -> void:
	assert_false(_input_state.jump_held, "Initial jump_held should be false")


func test_initial_jump_just_pressed() -> void:
	assert_false(_input_state.jump_just_pressed, "Initial jump_just_pressed should be false")


func test_initial_last_jump_time() -> void:
	assert_eq(_input_state.last_jump_time, 0, "Initial last_jump_time should be 0")


#endregion

#region Direction tests

func test_left_pressed_sets_direction() -> void:
	var event := InputEventAction.new()
	event.action = "Left"
	event.pressed = true
	_input_state.process_input(event)
	assert_eq(_input_state.move_direction, -1.0, "Left pressed should set direction to -1")


func test_right_pressed_sets_direction() -> void:
	var event := InputEventAction.new()
	event.action = "Right"
	event.pressed = true
	_input_state.process_input(event)
	assert_eq(_input_state.move_direction, 1.0, "Right pressed should set direction to 1")


func test_left_released_resets_direction() -> void:
	_input_state.move_direction = -1.0
	var event := InputEventAction.new()
	event.action = "Left"
	event.pressed = false
	_input_state.process_input(event)
	assert_eq(_input_state.move_direction, 0.0, "Left released should reset direction to 0")


func test_right_released_resets_direction() -> void:
	_input_state.move_direction = 1.0
	var event := InputEventAction.new()
	event.action = "Right"
	event.pressed = false
	_input_state.process_input(event)
	assert_eq(_input_state.move_direction, 0.0, "Right released should reset direction to 0")


func test_right_pressed_while_left_held() -> void:
	_input_state.move_direction = -1.0
	var event := InputEventAction.new()
	event.action = "Right"
	event.pressed = true
	_input_state.process_input(event)
	assert_eq(_input_state.move_direction, 1.0, "Right pressed should override left")


func test_left_released_while_right_held() -> void:
	_input_state.move_direction = 1.0  # Currently moving right
	var event := InputEventAction.new()
	event.action = "Left"
	event.pressed = false  # Left released (but we're moving right)
	_input_state.process_input(event)
	# Direction should stay at 1.0 since left release shouldn't affect right movement
	assert_eq(_input_state.move_direction, 1.0, "Left release shouldn't affect right movement")


#endregion

#region Jump tests

func test_jump_pressed_sets_held() -> void:
	var event := InputEventAction.new()
	event.action = "Jump"
	event.pressed = true
	_input_state.process_input(event)
	assert_true(_input_state.jump_held, "Jump pressed should set jump_held to true")


func test_jump_pressed_sets_just_pressed() -> void:
	var event := InputEventAction.new()
	event.action = "Jump"
	event.pressed = true
	_input_state.process_input(event)
	assert_true(_input_state.jump_just_pressed, "Jump pressed should set jump_just_pressed to true")


func test_jump_pressed_updates_time() -> void:
	var event := InputEventAction.new()
	event.action = "Jump"
	event.pressed = true
	_input_state.process_input(event)
	assert_gt(_input_state.last_jump_time, 0, "Jump pressed should update last_jump_time")


func test_jump_released_clears_held() -> void:
	_input_state.jump_held = true
	var event := InputEventAction.new()
	event.action = "Jump"
	event.pressed = false
	_input_state.process_input(event)
	assert_false(_input_state.jump_held, "Jump released should clear jump_held")


func test_non_jump_event_doesnt_clear_just_pressed() -> void:
	_input_state.jump_just_pressed = true
	var event := InputEventAction.new()
	event.action = "Right"
	event.pressed = true
	_input_state.process_input(event)
	# Only jump events should reset jump_just_pressed
	assert_true(_input_state.jump_just_pressed, "Non-jump event shouldn't clear jump_just_pressed")


#endregion

#region Reset tests

func test_reset_clears_direction() -> void:
	_input_state.move_direction = 1.0
	_input_state.reset()
	assert_eq(_input_state.move_direction, 0.0, "Reset should clear direction")


func test_reset_clears_jump_held() -> void:
	_input_state.jump_held = true
	_input_state.reset()
	assert_false(_input_state.jump_held, "Reset should clear jump_held")


func test_reset_clears_jump_just_pressed() -> void:
	_input_state.jump_just_pressed = true
	_input_state.reset()
	assert_false(_input_state.jump_just_pressed, "Reset should clear jump_just_pressed")


#endregion
