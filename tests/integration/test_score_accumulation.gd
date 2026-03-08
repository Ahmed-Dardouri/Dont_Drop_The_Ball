extends GutTest
## Integration tests for score accumulation
## Tests score manager behavior with AddScoreEvent

var _score: int = 0


func before_each() -> void:
	_score = 0
	# Reset pause state
	PauseEvent.state = false


func after_each() -> void:
	PauseEvent.state = false


func _add_score_handler(event: AddScoreEvent) -> void:
	_score += event._score


func test_score_accumulation_single() -> void:
	Events.add_listener(AddScoreEvent, Callable(self, "_add_score_handler"))

	# Simulate adding score
	await AddScoreEvent.invoke(10)

	assert_eq(_score, 10, "Score should be 10 after adding 10")

	Events.remove_listener(AddScoreEvent, Callable(self, "_add_score_handler"))


func test_score_accumulation_multiple() -> void:
	Events.add_listener(AddScoreEvent, Callable(self, "_add_score_handler"))

	await AddScoreEvent.invoke(5)
	await AddScoreEvent.invoke(10)
	await AddScoreEvent.invoke(3)

	assert_eq(_score, 18, "Score should accumulate correctly")

	Events.remove_listener(AddScoreEvent, Callable(self, "_add_score_handler"))


func test_score_blocked_when_paused() -> void:
	Events.add_listener(AddScoreEvent, Callable(self, "_add_score_handler"))

	# Pause the game
	PauseEvent.state = true

	# Try to add score - should be blocked
	await AddScoreEvent.invoke(10)

	assert_eq(_score, 0, "Score should not be added when paused")

	Events.remove_listener(AddScoreEvent, Callable(self, "_add_score_handler"))


func test_score_resumes_after_unpause() -> void:
	Events.add_listener(AddScoreEvent, Callable(self, "_add_score_handler"))

	# Pause and try to add - blocked
	PauseEvent.state = true
	await AddScoreEvent.invoke(10)
	assert_eq(_score, 0, "No score when paused")

	# Unpause and try again - should work
	PauseEvent.state = false
	await AddScoreEvent.invoke(10)
	assert_eq(_score, 10, "Score added after unpause")

	Events.remove_listener(AddScoreEvent, Callable(self, "_add_score_handler"))


func test_orb_score_values_integration() -> void:
	# Test that orb type to score mapping works through the event system
	Events.add_listener(AddScoreEvent, Callable(self, "_add_score_handler"))

	# Simulate orb collection events with different types
	# Blue orb = 2 points
	await AddScoreEvent.invoke(Constants.orb_score_blue)
	assert_eq(_score, 2, "Blue orb gives 2 points")

	# Red orb = 3 points
	await AddScoreEvent.invoke(Constants.orb_score_red)
	assert_eq(_score, 5, "Red orb gives 3 points (total 5)")

	# Half-solid orb = 8 points
	await AddScoreEvent.invoke(Constants.orb_score_half_solid)
	assert_eq(_score, 13, "Half-solid orb gives 8 points (total 13)")

	Events.remove_listener(AddScoreEvent, Callable(self, "_add_score_handler"))
