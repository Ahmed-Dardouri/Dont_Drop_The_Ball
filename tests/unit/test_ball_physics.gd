extends GutTest
## Unit tests for ball.gd physics functions
## Tests the pure math/physics logic without full scene instantiation

# We test the physics functions by creating a minimal test double
# that exposes the same logic

var _ball: RigidBody2D

func before_each() -> void:
	# Create a minimal RigidBody2D with ball physics logic
	_ball = RigidBody2D.new()
	# Set up default constants (matching ball.gd defaults)
	_ball.set_script(_create_ball_test_script())
	add_child_autofree(_ball)


func _create_ball_test_script() -> GDScript:
	# Create a script that mirrors ball.gd's physics functions
	var script = GDScript.new()
	script.source_code = """
extends RigidBody2D

var max_speed := 900.0
var fall_speed := 500.0
var air_friction := 9

func clamp_max_speed():
	if max_speed > 0.0:
		var v := linear_velocity
		var s := v.length()
		if s > max_speed:
			linear_velocity = v * (max_speed / s)

func clamp_fall_speed():
	if fall_speed > 0.0:
		var v := linear_velocity.y
		if v > fall_speed:
			linear_velocity.y = fall_speed

func apply_air_friction():
	linear_velocity.x = linear_velocity.x * (1.0 - air_friction/1000.0)
"""
	script.reload()
	return script


#region clamp_max_speed tests

func test_clamp_max_speed_no_clamp_when_under_limit() -> void:
	_ball.linear_velocity = Vector2(100, 100)  # magnitude ~141, under 900
	_ball.clamp_max_speed()
	assert_eq(_ball.linear_velocity, Vector2(100, 100), "Velocity should not change when under max")


func test_clamp_max_speed_clamps_when_over_limit() -> void:
	_ball.linear_velocity = Vector2(1000, 0)  # magnitude 1000, over 900
	_ball.clamp_max_speed()
	assert_almost_eq(_ball.linear_velocity.x, 900.0, 0.1, "X velocity should be clamped to max_speed")
	assert_eq(_ball.linear_velocity.y, 0.0, "Y velocity should remain 0")


func test_clamp_max_speed_preserves_direction() -> void:
	_ball.linear_velocity = Vector2(600, 800)  # magnitude 1000, over 900
	var original_angle := _ball.linear_velocity.angle()
	_ball.clamp_max_speed()
	var new_angle := _ball.linear_velocity.angle()
	# Direction should be preserved (same angle)
	assert_almost_eq(original_angle, new_angle, 0.001, "Direction should be preserved after clamping")


func test_clamp_max_speed_exactly_at_limit() -> void:
	_ball.linear_velocity = Vector2(900, 0)  # exactly at limit
	_ball.clamp_max_speed()
	assert_eq(_ball.linear_velocity.x, 900.0, "Velocity at limit should not change")


func test_clamp_max_speed_negative_velocity() -> void:
	_ball.linear_velocity = Vector2(-1000, 0)  # magnitude 1000, over 900, negative direction
	_ball.clamp_max_speed()
	assert_almost_eq(_ball.linear_velocity.x, -900.0, 0.1, "Negative velocity should be clamped correctly")


func test_clamp_max_speed_zero_max_does_nothing() -> void:
	_ball.max_speed = 0.0
	_ball.linear_velocity = Vector2(1000, 1000)
	_ball.clamp_max_speed()
	assert_eq(_ball.linear_velocity, Vector2(1000, 1000), "Zero max_speed should not clamp")


#endregion

#region clamp_fall_speed tests

func test_clamp_fall_speed_no_clamp_when_under_limit() -> void:
	_ball.linear_velocity = Vector2(0, 400)  # under fall_speed of 500
	_ball.clamp_fall_speed()
	assert_eq(_ball.linear_velocity.y, 400.0, "Fall speed should not change when under limit")


func test_clamp_fall_speed_clamps_when_over_limit() -> void:
	_ball.linear_velocity = Vector2(0, 800)  # over fall_speed of 500
	_ball.clamp_fall_speed()
	assert_eq(_ball.linear_velocity.y, 500.0, "Fall speed should be clamped to limit")


func test_clamp_fall_speed_negative_fall_preserved() -> void:
	_ball.linear_velocity = Vector2(0, -600)  # going up, negative
	_ball.clamp_fall_speed()
	assert_eq(_ball.linear_velocity.y, -600.0, "Upward velocity should not be affected")


func test_clamp_fall_speed_diagonal() -> void:
	_ball.linear_velocity = Vector2(200, 800)  # diagonal fall, Y over limit
	_ball.clamp_fall_speed()
	assert_eq(_ball.linear_velocity.x, 200.0, "X velocity should not be affected")
	assert_eq(_ball.linear_velocity.y, 500.0, "Y velocity should be clamped")


func test_clamp_fall_speed_zero_fall_speed_does_nothing() -> void:
	_ball.fall_speed = 0.0
	_ball.linear_velocity = Vector2(0, 1000)
	_ball.clamp_fall_speed()
	assert_eq(_ball.linear_velocity.y, 1000.0, "Zero fall_speed should not clamp")


#endregion

#region apply_air_friction tests

func test_apply_air_friction_reduces_horizontal_speed() -> void:
	_ball.linear_velocity = Vector2(1000, 0)
	_ball.apply_air_friction()
	# air_friction = 9, so new_x = 1000 * (1 - 9/1000) = 1000 * 0.991 = 991
	assert_almost_eq(_ball.linear_velocity.x, 991.0, 0.1, "Horizontal velocity should be reduced by friction")


func test_apply_air_friction_preserves_vertical() -> void:
	_ball.linear_velocity = Vector2(100, 500)
	_ball.apply_air_friction()
	assert_eq(_ball.linear_velocity.y, 500.0, "Vertical velocity should not be affected")


func test_apply_air_friction_negative_velocity() -> void:
	_ball.linear_velocity = Vector2(-1000, 0)
	_ball.apply_air_friction()
	assert_almost_eq(_ball.linear_velocity.x, -991.0, 0.1, "Negative horizontal velocity should be reduced")


func test_apply_air_friction_zero_velocity() -> void:
	_ball.linear_velocity = Vector2(0, 0)
	_ball.apply_air_friction()
	assert_eq(_ball.linear_velocity, Vector2(0, 0), "Zero velocity should remain zero")


func test_apply_air_friction_higher_friction() -> void:
	_ball.air_friction = 100  # 10% reduction
	_ball.linear_velocity = Vector2(1000, 0)
	_ball.apply_air_friction()
	assert_almost_eq(_ball.linear_velocity.x, 900.0, 0.1, "Higher friction should reduce velocity more")


func test_apply_air_friction_zero_friction() -> void:
	_ball.air_friction = 0
	_ball.linear_velocity = Vector2(1000, 0)
	_ball.apply_air_friction()
	assert_eq(_ball.linear_velocity.x, 1000.0, "Zero friction should not change velocity")


#endregion


#region Static BallPhysics class tests

func test_static_clamp_max_speed_over_limit() -> void:
	var result := BallPhysics.clamp_max_speed(Vector2(1000, 0), 900.0)
	assert_almost_eq(result.x, 900.0, 0.1, "Static clamp_max_speed should clamp")
	assert_eq(result.y, 0.0, "Y should be unchanged")


func test_static_clamp_max_speed_under_limit() -> void:
	var result := BallPhysics.clamp_max_speed(Vector2(100, 50), 900.0)
	assert_eq(result, Vector2(100, 50), "Should not change when under limit")


func test_static_clamp_max_speed_zero_limit() -> void:
	var result := BallPhysics.clamp_max_speed(Vector2(1000, 1000), 0.0)
	assert_eq(result, Vector2(1000, 1000), "Zero limit should not clamp")


func test_static_clamp_fall_speed_over_limit() -> void:
	var result := BallPhysics.clamp_fall_speed(Vector2(100, 600), 500.0)
	assert_eq(result.x, 100.0, "X should be unchanged")
	assert_eq(result.y, 500.0, "Y should be clamped")


func test_static_clamp_fall_speed_under_limit() -> void:
	var result := BallPhysics.clamp_fall_speed(Vector2(100, 400), 500.0)
	assert_eq(result, Vector2(100, 400), "Should not change when under limit")


func test_static_clamp_fall_speed_negative() -> void:
	var result := BallPhysics.clamp_fall_speed(Vector2(100, -600), 500.0)
	assert_eq(result.y, -600.0, "Upward velocity should not be affected")


func test_static_apply_air_friction() -> void:
	var result := BallPhysics.apply_air_friction(Vector2(1000, 50), 9.0)
	assert_almost_eq(result.x, 991.0, 0.1, "X should be reduced by friction")
	assert_eq(result.y, 50.0, "Y should be unchanged")


func test_static_apply_air_friction_zero() -> void:
	var result := BallPhysics.apply_air_friction(Vector2(100, 50), 0.0)
	assert_eq(result, Vector2(100, 50), "Zero friction should not change velocity")


func test_static_process_velocity() -> void:
	var config := BallPhysicsConfig.new()
	var result := BallPhysics.process_velocity(Vector2(1000, 600), config)
	# Should clamp max_speed (magnitude 1166 -> 900), then apply friction
	# After max_speed clamp: (771.5, 462.9), Y is already under 500 so no fall clamp
	assert_almost_eq(result.length(), 900.0, 50.0, "Process velocity should clamp total speed")
	# Friction reduces X: 771.5 * (1 - 9/1000) = 764.6
	assert_almost_eq(result.x, 764.6, 1.0, "X should be reduced by friction")


func test_static_process_velocity_clamps_fall() -> void:
	var config := BallPhysicsConfig.new()
	# Use a velocity where Y exceeds max_fall_speed after max_speed clamp
	var result := BallPhysics.process_velocity(Vector2(0, 600), config)
	assert_eq(result.y, 500.0, "Fall speed should be clamped when exceeds limit")


func test_static_process_velocity_null_config() -> void:
	var result := BallPhysics.process_velocity(Vector2(100, 50), null)
	assert_eq(result, Vector2(100, 50), "Null config should return unchanged velocity")


#endregion
