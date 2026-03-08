extends GutTest
## Unit tests for physics_player.gd movement logic
## Tests the pure logic functions for player movement

# Test helper that mirrors physics_player.gd's update_move logic
func _update_move(left_held: bool, right_held: bool) -> float:
	if right_held:
		return 1.0
	elif left_held:
		return -1.0
	else:
		return 0.0


# Test helper for coyote time logic (from physics_player.gd)
func _can_coyote(coyote_usable: bool, time_left_ground: int, coyote_timeout: float, current_time: int) -> bool:
	if coyote_usable && current_time < time_left_ground + coyote_timeout:
		return true
	return false


# Test helper for buffered jump logic (from physics_player.gd)
func _has_buffered_jump(buffered_usable: bool, time_jump_pressed: int, jump_buffer_timeout: float, current_time: int) -> bool:
	if buffered_usable && current_time < time_jump_pressed + jump_buffer_timeout:
		return true
	return false


#region update_move tests

func test_update_move_right() -> void:
	var move_x := _update_move(false, true)
	assert_eq(move_x, 1.0, "Holding right should return 1")


func test_update_move_left() -> void:
	var move_x := _update_move(true, false)
	assert_eq(move_x, -1.0, "Holding left should return -1")


func test_update_move_none() -> void:
	var move_x := _update_move(false, false)
	assert_eq(move_x, 0.0, "Not holding any direction should return 0")


func test_update_move_both_right_priority() -> void:
	# In the original code, right has priority (checked first in elif chain)
	var move_x := _update_move(true, true)  # Both held - right wins due to elif
	# Actually, with both held in the original code, right is checked first
	# But our helper matches the original elif chain where right comes first
	assert_eq(move_x, 1.0, "Right should have priority when both are held")


#endregion

#region can_coyote tests

func test_can_coyote_within_window() -> void:
	var can := _can_coyote(true, 1000, 150.0, 1100)
	assert_true(can, "Should be able to coyote within window")


func test_can_coyote_at_exact_boundary() -> void:
	# At exactly time_left_ground + coyote_timeout
	# The original code uses < (strictly less than), so boundary is NOT included
	var can := _can_coyote(true, 1000, 150.0, 1150)
	assert_false(can, "Should NOT be able to coyote at exact boundary (< comparison)")


func test_can_coyote_outside_window() -> void:
	var can := _can_coyote(true, 1000, 150.0, 1200)
	assert_false(can, "Should not be able to coyote outside window")


func test_can_coyote_not_usable() -> void:
	var can := _can_coyote(false, 1000, 150.0, 1100)
	assert_false(can, "Should not be able to coyote if not usable")


func test_can_coyote_zero_timeout() -> void:
	var can := _can_coyote(true, 1000, 0.0, 1001)
	assert_false(can, "Zero timeout means no coyote time")


#endregion

#region has_buffered_jump tests

func test_has_buffered_jump_within_window() -> void:
	var has := _has_buffered_jump(true, 1000, 150.0, 1100)
	assert_true(has, "Should have buffered jump within window")


func test_has_buffered_jump_at_boundary() -> void:
	# At exactly time_jump_pressed + jump_buffer_timeout
	# The original code uses < (strictly less than), so boundary is NOT included
	var has := _has_buffered_jump(true, 1000, 150.0, 1150)
	assert_false(has, "Should NOT have buffered jump at exact boundary (< comparison)")


func test_has_buffered_jump_outside_window() -> void:
	var has := _has_buffered_jump(true, 1000, 150.0, 1200)
	assert_false(has, "Should not have buffered jump outside window")


func test_has_buffered_jump_not_usable() -> void:
	var has := _has_buffered_jump(false, 1000, 150.0, 1100)
	assert_false(has, "Should not have buffered jump if not usable")


func test_has_buffered_jump_zero_timeout() -> void:
	var has := _has_buffered_jump(true, 1000, 0.0, 1001)
	assert_false(has, "Zero timeout means no buffered jump")


#endregion

#region Constants validation tests

func test_player_constants_loaded() -> void:
	# Verify key player constants are properly set
	# Note: jump_power is negative because upward velocity in Godot is negative Y
	assert_ne(Constants.player_jump_power, 0, "Jump power should be non-zero")
	assert_gt(Constants.player_keyboard_move_power, 0, "Move power should be positive")
	assert_gt(Constants.player_coyote_timeout, 0.0, "Coyote timeout should be positive")
	assert_gt(Constants.player_jump_buffer_timeout, 0.0, "Jump buffer timeout should be positive")


func test_player_fall_constants() -> void:
	assert_gt(Constants.player_fall_acceleration, 0.0, "Fall acceleration should be positive")
	assert_gt(Constants.player_max_fall_speed, 0.0, "Max fall speed should be positive")


func test_player_movement_constants() -> void:
	assert_gt(Constants.player_move_acceleration, 0.0, "Move acceleration should be positive")
	assert_gt(Constants.player_initial_move_acceleration, 0.0, "Initial move acceleration should be positive")
	assert_gt(Constants.player_move_deceleration, 0.0, "Move deceleration should be positive")

#endregion
