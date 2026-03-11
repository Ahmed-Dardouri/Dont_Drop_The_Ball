extends GutTest
## Unit tests for ModeConfig resource class
## Tests creation, defaults, validation, and resource loading


#region Default Values Tests

func test_mode_config_default_mode_id() -> void:
	var config := ModeConfig.new()
	assert_eq(config.mode_id, "", "Default mode_id should be empty string")


func test_mode_config_default_display_name() -> void:
	var config := ModeConfig.new()
	assert_eq(config.display_name, "", "Default display_name should be empty string")


func test_mode_config_default_description() -> void:
	var config := ModeConfig.new()
	assert_eq(config.description, "", "Default description should be empty string")


func test_mode_config_default_icon() -> void:
	var config := ModeConfig.new()
	assert_null(config.icon, "Default icon should be null")


func test_mode_config_default_implementation() -> void:
	var config := ModeConfig.new()
	assert_null(config.implementation, "Default implementation should be null")


func test_mode_config_default_orb_pool() -> void:
	var config := ModeConfig.new()
	assert_eq(config.orb_pool.size(), 0, "Default orb_pool should be empty")


func test_mode_config_default_spawn_interval() -> void:
	var config := ModeConfig.new()
	assert_eq(config.spawn_interval, 0.0, "Default spawn_interval should be 0.0")


func test_mode_config_default_max_orbs() -> void:
	var config := ModeConfig.new()
	assert_eq(config.max_orbs, 0, "Default max_orbs should be 0")


func test_mode_config_default_hud_metric() -> void:
	var config := ModeConfig.new()
	assert_eq(config.hud_metric, "score", "Default hud_metric should be 'score'")


func test_mode_config_default_has_win() -> void:
	var config := ModeConfig.new()
	assert_false(config.has_win, "Default has_win should be false")


#endregion

#region Validation Tests

func test_mode_config_validation_valid() -> void:
	var config := ModeConfig.new()
	config.mode_id = "endless"
	config.display_name = "Endless"
	assert_true(config.is_valid(), "Config with mode_id and display_name should be valid")


func test_mode_config_validation_empty_mode_id() -> void:
	var config := ModeConfig.new()
	config.mode_id = ""
	config.display_name = "Test"
	assert_false(config.is_valid(), "Config with empty mode_id should be invalid")


func test_mode_config_validation_empty_display_name() -> void:
	var config := ModeConfig.new()
	config.mode_id = "test"
	config.display_name = ""
	assert_false(config.is_valid(), "Config with empty display_name should be invalid")


func test_mode_config_validation_whitespace_only() -> void:
	var config := ModeConfig.new()
	config.mode_id = "   "
	config.display_name = "Test"
	assert_false(config.is_valid(), "Config with whitespace-only mode_id should be invalid")


#endregion

#region Resource Tests

func test_mode_config_is_resource() -> void:
	var config := ModeConfig.new()
	assert_true(config is Resource, "ModeConfig should extend Resource")


func test_mode_config_can_be_duplicated() -> void:
	var original := ModeConfig.new()
	original.mode_id = "test_mode"
	original.display_name = "Test Mode"
	original.spawn_interval = 1.5
	original.max_orbs = 15
	original.has_win = true

	var copy := original.duplicate()
	assert_eq(copy.mode_id, "test_mode", "Duplicated config should have same mode_id")
	assert_eq(copy.display_name, "Test Mode", "Duplicated config should have same display_name")
	assert_eq(copy.spawn_interval, 1.5, "Duplicated config should have same spawn_interval")
	assert_eq(copy.max_orbs, 15, "Duplicated config should have same max_orbs")
	assert_true(copy.has_win, "Duplicated config should have same has_win")


func test_mode_config_load_endless_mode_resource() -> void:
	var config := load("res://resources/modes/endless_mode.tres") as ModeConfig
	assert_not_null(config, "Should be able to load endless_mode.tres")
	assert_eq(config.mode_id, "endless", "Loaded config should have mode_id 'endless'")
	assert_eq(config.display_name, "Endless", "Loaded config should have display_name 'Endless'")


#endregion
