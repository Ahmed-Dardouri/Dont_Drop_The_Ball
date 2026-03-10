extends GutTest
## Unit tests for OrbBehavior abstract base class
## Tests that base methods are callable without crash


#region Resource Type Tests

func test_orb_behavior_is_resource() -> void:
	var behavior := OrbBehavior.new()
	assert_true(behavior is Resource, "OrbBehavior should extend Resource")


func test_orb_behavior_has_class_name() -> void:
	var behavior := OrbBehavior.new()
	assert_not_null(behavior, "OrbBehavior should be instantiable via class_name")


#endregion

#region Execute Method Tests

func test_execute_callable_with_empty_context() -> void:
	var behavior := OrbBehavior.new()
	# Should not crash when called with empty dictionary
	behavior.execute({})
	assert_true(true, "execute() should not crash with empty context")


func test_execute_callable_with_context() -> void:
	var behavior := OrbBehavior.new()
	var context := {
		"orb": null,
		"orb_data": null,
		"collector": null
	}
	# Should not crash when called with valid context structure
	behavior.execute(context)
	assert_true(true, "execute() should not crash with context dictionary")


#endregion

#region Process Method Tests

func test_process_callable_with_null_orb() -> void:
	var behavior := OrbBehavior.new()
	# Should not crash when called with null orb
	behavior.process(null, 0.016)
	assert_true(true, "process() should not crash with null orb")


func test_process_callable_with_delta() -> void:
	var behavior := OrbBehavior.new()
	# Should not crash with various delta values
	behavior.process(null, 0.0)
	behavior.process(null, 1.0)
	behavior.process(null, -0.5)
	assert_true(true, "process() should not crash with various delta values")


#endregion

#region On Spawn Method Tests

func test_on_spawn_callable_with_null_orb() -> void:
	var behavior := OrbBehavior.new()
	# Should not crash when called with null orb
	behavior.on_spawn(null, 0.5)
	assert_true(true, "on_spawn() should not crash with null orb")


func test_on_spawn_callable_with_progress() -> void:
	var behavior := OrbBehavior.new()
	# Should not crash with various progress values
	behavior.on_spawn(null, 0.0)
	behavior.on_spawn(null, 0.5)
	behavior.on_spawn(null, 1.0)
	assert_true(true, "on_spawn() should not crash with various progress values")


#endregion

#region Behavior ID Tests

func test_behavior_id_default_empty() -> void:
	var behavior := OrbBehavior.new()
	assert_eq(behavior.behavior_id, "", "Default behavior_id should be empty string")


func test_behavior_id_settable() -> void:
	var behavior := OrbBehavior.new()
	behavior.behavior_id = "test_behavior"
	assert_eq(behavior.behavior_id, "test_behavior", "behavior_id should be settable")


#endregion

#region Extensibility Tests

func test_orb_behavior_can_be_extended() -> void:
	# Create a custom behavior extending OrbBehavior
	var custom_behavior := _create_custom_behavior()
	assert_not_null(custom_behavior, "OrbBehavior should be extendable")


func _create_custom_behavior() -> OrbBehavior:
	# This simulates creating a concrete behavior
	var behavior := OrbBehavior.new()
	behavior.behavior_id = "custom_test"
	return behavior


#endregion
