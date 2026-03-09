extends GutTest
## Unit tests for BallPhysicsConfig and PlayerPhysicsConfig resources
## Tests default values and custom value assignment


#region BallPhysicsConfig Tests

func test_ball_physics_config_default_max_speed() -> void:
	var config := BallPhysicsConfig.new()
	assert_eq(config.max_speed, 900.0, "Default max_speed should be 900.0")


func test_ball_physics_config_default_max_fall_speed() -> void:
	var config := BallPhysicsConfig.new()
	assert_eq(config.max_fall_speed, 500.0, "Default max_fall_speed should be 500.0")


func test_ball_physics_config_default_air_friction() -> void:
	var config := BallPhysicsConfig.new()
	assert_eq(config.air_friction, 9.0, "Default air_friction should be 9.0")


func test_ball_physics_config_custom_max_speed() -> void:
	var config := BallPhysicsConfig.new()
	config.max_speed = 1000.0
	assert_eq(config.max_speed, 1000.0, "Custom max_speed should be 1000.0")


func test_ball_physics_config_custom_max_fall_speed() -> void:
	var config := BallPhysicsConfig.new()
	config.max_fall_speed = 600.0
	assert_eq(config.max_fall_speed, 600.0, "Custom max_fall_speed should be 600.0")


func test_ball_physics_config_custom_air_friction() -> void:
	var config := BallPhysicsConfig.new()
	config.air_friction = 15.0
	assert_eq(config.air_friction, 15.0, "Custom air_friction should be 15.0")


func test_ball_physics_config_all_custom_values() -> void:
	var config := BallPhysicsConfig.new()
	config.max_speed = 800.0
	config.max_fall_speed = 400.0
	config.air_friction = 12.0
	assert_eq(config.max_speed, 800.0, "Custom max_speed should be 800.0")
	assert_eq(config.max_fall_speed, 400.0, "Custom max_fall_speed should be 400.0")
	assert_eq(config.air_friction, 12.0, "Custom air_friction should be 12.0")


#endregion


#region PlayerPhysicsConfig Tests

func test_player_physics_config_default_jump_power() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.jump_power, -700, "Default jump_power should be -700")


func test_player_physics_config_default_move_speed() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.move_speed, 120, "Default move_speed should be 120")


func test_player_physics_config_default_acceleration() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.acceleration, 1500.0, "Default acceleration should be 1500.0")


func test_player_physics_config_default_initial_acceleration() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.initial_acceleration, 2000.0, "Default initial_acceleration should be 2000.0")


func test_player_physics_config_default_deceleration() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.deceleration, 10000.0, "Default deceleration should be 10000.0")


func test_player_physics_config_default_coyote_timeout() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.coyote_timeout, 150.0, "Default coyote_timeout should be 150.0")


func test_player_physics_config_default_jump_buffer_timeout() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.jump_buffer_timeout, 150.0, "Default jump_buffer_timeout should be 150.0")


func test_player_physics_config_default_fall_acceleration() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.fall_acceleration, 1800.0, "Default fall_acceleration should be 1800.0")


func test_player_physics_config_default_max_fall_speed() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.max_fall_speed, 800.0, "Default max_fall_speed should be 800.0")


func test_player_physics_config_default_grounding_force() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.grounding_force, 1.5, "Default grounding_force should be 1.5")


func test_player_physics_config_default_early_jump_gravity_modifier() -> void:
	var config := PlayerPhysicsConfig.new()
	assert_eq(config.early_jump_gravity_modifier, 3.0, "Default early_jump_gravity_modifier should be 3.0")


func test_player_physics_config_custom_jump_power() -> void:
	var config := PlayerPhysicsConfig.new()
	config.jump_power = -800
	assert_eq(config.jump_power, -800, "Custom jump_power should be -800")


func test_player_physics_config_custom_coyote_timeout() -> void:
	var config := PlayerPhysicsConfig.new()
	config.coyote_timeout = 200.0
	assert_eq(config.coyote_timeout, 200.0, "Custom coyote_timeout should be 200.0")


func test_player_physics_config_all_custom_values() -> void:
	var config := PlayerPhysicsConfig.new()
	config.jump_power = -900
	config.move_speed = 150
	config.acceleration = 2000.0
	config.initial_acceleration = 2500.0
	config.deceleration = 12000.0
	config.coyote_timeout = 180.0
	config.jump_buffer_timeout = 200.0
	config.fall_acceleration = 2000.0
	config.max_fall_speed = 900.0
	config.grounding_force = 2.0
	config.early_jump_gravity_modifier = 4.0

	assert_eq(config.jump_power, -900, "Custom jump_power should be -900")
	assert_eq(config.move_speed, 150, "Custom move_speed should be 150")
	assert_eq(config.acceleration, 2000.0, "Custom acceleration should be 2000.0")
	assert_eq(config.initial_acceleration, 2500.0, "Custom initial_acceleration should be 2500.0")
	assert_eq(config.deceleration, 12000.0, "Custom deceleration should be 12000.0")
	assert_eq(config.coyote_timeout, 180.0, "Custom coyote_timeout should be 180.0")
	assert_eq(config.jump_buffer_timeout, 200.0, "Custom jump_buffer_timeout should be 200.0")
	assert_eq(config.fall_acceleration, 2000.0, "Custom fall_acceleration should be 2000.0")
	assert_eq(config.max_fall_speed, 900.0, "Custom max_fall_speed should be 900.0")
	assert_eq(config.grounding_force, 2.0, "Custom grounding_force should be 2.0")
	assert_eq(config.early_jump_gravity_modifier, 4.0, "Custom early_jump_gravity_modifier should be 4.0")


#endregion
