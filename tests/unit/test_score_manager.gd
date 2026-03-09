extends GutTest
## Unit tests for ScoreManager singleton
## Tests score tracking with signal-based UI updates

var _score_changed_count: int = 0
var _last_score_value: int = -1
var _high_score_changed_count: int = 0
var _last_high_score_value: int = -1


func before_each() -> void:
	# Reset state and counters before each test
	_score_changed_count = 0
	_last_score_value = -1
	_high_score_changed_count = 0
	_last_high_score_value = -1
	ScoreManager.reset_score()
	ScoreManager.set_high_score(0)


func after_each() -> void:
	# Disconnect signals to prevent accumulation across tests
	if ScoreManager.score_changed.is_connected(_on_score_changed):
		ScoreManager.score_changed.disconnect(_on_score_changed)
	if ScoreManager.high_score_changed.is_connected(_on_high_score_changed):
		ScoreManager.high_score_changed.disconnect(_on_high_score_changed)


func _on_score_changed(new_score: int) -> void:
	_score_changed_count += 1
	_last_score_value = new_score


func _on_high_score_changed(new_high: int) -> void:
	_high_score_changed_count += 1
	_last_high_score_value = new_high


# Test 1: Initial Score is Zero
func test_initial_score_is_zero() -> void:
	assert_eq(ScoreManager.get_score(), 0, "Initial score should be 0")


# Test 2: Add Score Increases
func test_add_score_increases_score() -> void:
	var result: int = ScoreManager.add_score(10)
	assert_eq(ScoreManager.get_score(), 10, "Score should be 10 after adding 10")
	assert_eq(result, 10, "add_score() should return new score (10)")


# Test 3: Score Accumulates
func test_score_accumulates() -> void:
	ScoreManager.add_score(5)
	var result: int = ScoreManager.add_score(3)
	assert_eq(ScoreManager.get_score(), 8, "Score should accumulate to 8")
	assert_eq(result, 8, "add_score() should return new score (8)")


# Test 4: High Score Updates When Beaten
func test_high_score_updates_when_beaten() -> void:
	ScoreManager.set_high_score(0)
	ScoreManager.add_score(100)
	assert_eq(ScoreManager.get_high_score(), 100, "High score should be 100 after beating 0")


# Test 5: High Score Not Updated When Lower
func test_high_score_not_updated_when_lower() -> void:
	ScoreManager.set_high_score(200)
	ScoreManager.add_score(50)
	assert_eq(ScoreManager.get_high_score(), 200, "High score should remain 200 when not beaten")


# Test 6: Reset Clears Current Only
func test_reset_clears_current_only() -> void:
	ScoreManager.add_score(100)
	assert_eq(ScoreManager.get_high_score(), 100, "High score should be 100 after adding")
	ScoreManager.reset_score()
	assert_eq(ScoreManager.get_score(), 0, "Score should be 0 after reset")
	assert_eq(ScoreManager.get_high_score(), 100, "High score should remain 100 after reset")


# Test 7: Score Signal Emits
func test_score_signal_emits() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.add_score(42)
	assert_eq(_score_changed_count, 1, "score_changed should emit once")
	assert_eq(_last_score_value, 42, "score_changed should receive 42")


func test_score_signal_emits_on_multiple_adds() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)
	ScoreManager.add_score(10)
	ScoreManager.add_score(5)
	assert_eq(_score_changed_count, 2, "score_changed should emit twice")
	assert_eq(_last_score_value, 15, "last score_changed should receive 15")


# Test 8: High Score Signal Emits
func test_high_score_signal_emits_when_beaten() -> void:
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	ScoreManager.add_score(100)
	assert_eq(_high_score_changed_count, 1, "high_score_changed should emit once")
	assert_eq(_last_high_score_value, 100, "high_score_changed should receive 100")


func test_high_score_signal_does_not_emit_when_not_beaten() -> void:
	ScoreManager.set_high_score(200)
	ScoreManager.high_score_changed.connect(_on_high_score_changed)
	ScoreManager.add_score(50)
	assert_eq(_high_score_changed_count, 0, "high_score_changed should not emit when not beaten")


# Test 9: set_high_score works
func test_set_high_score() -> void:
	ScoreManager.set_high_score(500)
	assert_eq(ScoreManager.get_high_score(), 500, "set_high_score should set high score")


func test_get_high_score_default() -> void:
	ScoreManager.set_high_score(0)
	assert_eq(ScoreManager.get_high_score(), 0, "get_high_score should return 0 by default")
