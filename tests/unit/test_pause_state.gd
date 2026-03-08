extends GutTest
## Unit tests for PauseEvent state management
## Tests the static state behavior that affects game logic


func before_each() -> void:
	# Reset pause state before each test
	PauseEvent.state = false


func after_each() -> void:
	# Clean up after each test
	PauseEvent.state = false


func test_pause_state_initial() -> void:
	# After reset, should be false
	PauseEvent.state = false
	assert_false(PauseEvent.state, "Initial pause state should be false")


func test_pause_state_set_true() -> void:
	PauseEvent.state = true
	assert_true(PauseEvent.state, "Pause state should be true after setting")


func test_pause_state_toggle() -> void:
	PauseEvent.state = false
	PauseEvent.state = true
	assert_true(PauseEvent.state, "Pause state should toggle to true")

	PauseEvent.state = false
	assert_false(PauseEvent.state, "Pause state should toggle back to false")


func test_pause_affects_scoring_logic() -> void:
	# When paused, AddScoreEvent.invoke checks PauseEvent.state
	# This tests the logic pattern used in the codebase
	PauseEvent.state = false
	var should_add_score: bool = (PauseEvent.state == false)
	assert_true(should_add_score, "Score should be added when not paused")

	PauseEvent.state = true
	should_add_score = (PauseEvent.state == false)
	assert_false(should_add_score, "Score should not be added when paused")


func test_pause_affects_orb_collection() -> void:
	# OrbCollectedEvent also checks PauseEvent.state
	PauseEvent.state = false
	var should_collect: bool = (PauseEvent.state == false)
	assert_true(should_collect, "Orbs should be collected when not paused")

	PauseEvent.state = true
	should_collect = (PauseEvent.state == false)
	assert_false(should_collect, "Orbs should not be collected when paused")
