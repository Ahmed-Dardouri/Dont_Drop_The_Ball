extends GutTest
## Unit tests for OrbRegistry static class


func before_each() -> void:
	OrbRegistry.reset()


#region Initialize tests

func test_initialize_registers_blue() -> void:
	OrbRegistry.initialize()
	var def := OrbRegistry.get_definition(&"blue")
	assert_ne(def, null, "Blue orb should be registered")
	assert_eq(def.score_value, 2, "Blue orb score should be 2")


func test_initialize_registers_red() -> void:
	OrbRegistry.initialize()
	var def := OrbRegistry.get_definition(&"red")
	assert_ne(def, null, "Red orb should be registered")
	assert_eq(def.score_value, 3, "Red orb score should be 3")


func test_initialize_registers_half_solid() -> void:
	OrbRegistry.initialize()
	var def := OrbRegistry.get_definition(&"half_solid")
	assert_ne(def, null, "Half solid orb should be registered")
	assert_eq(def.score_value, 8, "Half solid orb score should be 8")
	assert_true(def.has_physics_body, "Half solid orb should have physics body")


func test_initialize_idempotent() -> void:
	OrbRegistry.initialize()
	OrbRegistry.initialize()  # Call twice
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 3, "Should only register once")


#endregion

#region Unknown Type tests

func test_unknown_type_returns_null() -> void:
	OrbRegistry.initialize()
	var def := OrbRegistry.get_definition(&"unknown")
	assert_null(def, "Unknown type should return null")


#endregion

#region Custom Registration tests

func test_register_custom() -> void:
	var def := OrbDefinition.new()
	def.type_name = &"custom"
	def.score_value = 99
	OrbRegistry.register(def)
	var retrieved := OrbRegistry.get_definition(&"custom")
	assert_eq(retrieved.score_value, 99, "Custom orb should be registered")


func test_register_null_handled() -> void:
	OrbRegistry.register(null)
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 0, "Null registration should be ignored")


func test_register_null_type_name_handled() -> void:
	var def := OrbDefinition.new()
	def.type_name = null  # type_name is null
	OrbRegistry.register(def)
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 0, "Null type_name registration should be ignored")


#endregion

#region Get All Definitions tests

func test_get_all_definitions() -> void:
	OrbRegistry.initialize()
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 3, "Should have 3 default definitions")


func test_get_all_definitions_empty() -> void:
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 0, "Empty registry should return empty array")


#endregion

#region Weighted Random tests

func test_weighted_random_returns_valid() -> void:
	OrbRegistry.initialize()
	for i in range(10):
		var def := OrbRegistry.get_weighted_random()
		assert_ne(def, null, "Should return valid definition")


func test_weighted_random_auto_initialize() -> void:
	# Should auto-initialize if empty
	var def := OrbRegistry.get_weighted_random()
	assert_ne(def, null, "Should auto-initialize and return valid definition")


func test_weighted_random_empty_registry() -> void:
	# Reset and don't initialize - but get_weighted_random should auto-initialize
	OrbRegistry.reset()
	# The implementation auto-initializes when empty
	var def := OrbRegistry.get_weighted_random()
	assert_ne(def, null, "Should return definition after auto-initialize")


#endregion

#region Reset tests

func test_reset_clears_definitions() -> void:
	OrbRegistry.initialize()
	OrbRegistry.reset()
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 0, "Reset should clear all definitions")


func test_reset_clears_initialized_flag() -> void:
	OrbRegistry.initialize()
	OrbRegistry.reset()
	OrbRegistry.initialize()
	var all := OrbRegistry.get_all_definitions()
	assert_eq(all.size(), 3, "Should be able to reinitialize after reset")


#endregion
