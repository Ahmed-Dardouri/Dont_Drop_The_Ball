extends GutTest
## Unit tests for GameOverEvent
## Tests that game over event respects pause state

var _event_fired: bool = false
var _call_count: int = 0


func before_each() -> void:
	GameState.is_paused = false
	_event_fired = false
	_call_count = 0


func after_each() -> void:
	GameState.is_paused = false
	Events.remove_listener(GameOverEvent, _on_game_over_event)


func _on_game_over_event(_event: GameOverEvent) -> void:
	_event_fired = true
	_call_count += 1


func test_game_over_event_fires_when_not_paused() -> void:
	Events.add_listener(GameOverEvent, _on_game_over_event)
	GameState.is_paused = false
	GameOverEvent.invoke()

	# Wait for async event to complete
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(_event_fired, "GameOverEvent should fire when game is not paused")


func test_game_over_event_blocked_when_paused() -> void:
	Events.add_listener(GameOverEvent, _on_game_over_event)
	GameState.is_paused = true
	GameOverEvent.invoke()

	# Wait for async event to complete
	await get_tree().process_frame
	await get_tree().process_frame

	assert_false(_event_fired, "GameOverEvent should not fire when game is paused")


func test_game_over_event_toggles_with_pause() -> void:
	Events.add_listener(GameOverEvent, _on_game_over_event)

	# First invocation - not paused
	GameState.is_paused = false
	GameOverEvent.invoke()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(_call_count, 1, "First invocation should fire")

	# Second invocation - paused
	GameState.is_paused = true
	GameOverEvent.invoke()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(_call_count, 1, "Second invocation should be blocked")

	# Third invocation - not paused again
	GameState.is_paused = false
	GameOverEvent.invoke()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(_call_count, 2, "Third invocation should fire")
