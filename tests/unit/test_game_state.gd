extends GutTest
## Unit tests for GameState singleton
## Tests centralized game state management with signal-based notifications

var _pause_changed_count: int = 0
var _last_pause_value: bool = false
var _mode_changed_count: int = 0
var _last_mode_value: int = -1


func before_each() -> void:
	# Reset state and counters before each test
	_pause_changed_count = 0
	_last_pause_value = false
	_mode_changed_count = 0
	_last_mode_value = -1
	GameState.reset()


func after_each() -> void:
	# Disconnect signals to prevent accumulation across tests
	if GameState.pause_changed.is_connected(_on_pause_changed):
		GameState.pause_changed.disconnect(_on_pause_changed)
	if GameState.mode_changed.is_connected(_on_mode_changed):
		GameState.mode_changed.disconnect(_on_mode_changed)


func _on_pause_changed(is_paused: bool) -> void:
	_pause_changed_count += 1
	_last_pause_value = is_paused


func _on_mode_changed(new_mode: Enums.GameMode) -> void:
	_mode_changed_count += 1
	_last_mode_value = new_mode


# Test 1: Initial State
func test_initial_state_is_paused_false() -> void:
	assert_false(GameState.is_paused, "Initial is_paused should be false")


func test_initial_state_mode_is_menu() -> void:
	assert_eq(GameState.current_mode, Enums.GameMode.MENU, "Initial current_mode should be MENU")


# Test 2: Pause Toggle Works
func test_toggle_pause_from_false_to_true() -> void:
	GameState.is_paused = false
	GameState.toggle_pause()
	assert_true(GameState.is_paused, "After toggle_pause(), is_paused should be true")


func test_toggle_pause_from_true_to_false() -> void:
	GameState.is_paused = true
	GameState.toggle_pause()
	assert_false(GameState.is_paused, "After toggle_pause() from true, is_paused should be false")


func test_toggle_pause_toggles() -> void:
	GameState.is_paused = false
	GameState.toggle_pause()
	assert_true(GameState.is_paused, "First toggle should make is_paused true")
	GameState.toggle_pause()
	assert_false(GameState.is_paused, "Second toggle should make is_paused false")


# Test 3: Pause Signal Emits
func test_pause_signal_emits_on_set_true() -> void:
	GameState.pause_changed.connect(_on_pause_changed)
	GameState.is_paused = true
	assert_eq(_pause_changed_count, 1, "pause_changed should emit once")
	assert_true(_last_pause_value, "pause_changed should receive true")


func test_pause_signal_emits_on_set_false() -> void:
	GameState.is_paused = true  # Set to true first
	GameState.pause_changed.connect(_on_pause_changed)
	GameState.is_paused = false
	assert_eq(_pause_changed_count, 1, "pause_changed should emit once")
	assert_false(_last_pause_value, "pause_changed should receive false")


func test_pause_signal_does_not_emit_on_same_value() -> void:
	GameState.pause_changed.connect(_on_pause_changed)
	GameState.is_paused = false  # Same as initial
	assert_eq(_pause_changed_count, 0, "pause_changed should not emit when value unchanged")


# Test 4: Mode Signal Emits
func test_mode_signal_emits_on_change() -> void:
	GameState.mode_changed.connect(_on_mode_changed)
	GameState.current_mode = Enums.GameMode.PLAYING
	assert_eq(_mode_changed_count, 1, "mode_changed should emit once")
	assert_eq(_last_mode_value, Enums.GameMode.PLAYING, "mode_changed should receive PLAYING")


func test_mode_signal_emits_game_over() -> void:
	GameState.mode_changed.connect(_on_mode_changed)
	GameState.current_mode = Enums.GameMode.GAME_OVER
	assert_eq(_mode_changed_count, 1, "mode_changed should emit once")
	assert_eq(_last_mode_value, Enums.GameMode.GAME_OVER, "mode_changed should receive GAME_OVER")


func test_mode_signal_does_not_emit_on_same_value() -> void:
	GameState.mode_changed.connect(_on_mode_changed)
	GameState.current_mode = Enums.GameMode.MENU  # Same as initial
	assert_eq(_mode_changed_count, 0, "mode_changed should not emit when value unchanged")


# Test 5: Reset Clears State
func test_reset_clears_pause() -> void:
	GameState.is_paused = true
	GameState.reset()
	assert_false(GameState.is_paused, "After reset(), is_paused should be false")


func test_reset_clears_mode() -> void:
	GameState.current_mode = Enums.GameMode.GAME_OVER
	GameState.reset()
	assert_eq(GameState.current_mode, Enums.GameMode.MENU, "After reset(), current_mode should be MENU")


func test_reset_clears_all_state() -> void:
	GameState.is_paused = true
	GameState.current_mode = Enums.GameMode.PAUSED
	GameState.reset()
	assert_false(GameState.is_paused, "After reset(), is_paused should be false")
	assert_eq(GameState.current_mode, Enums.GameMode.MENU, "After reset(), current_mode should be MENU")
