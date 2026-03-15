extends Node
## Score tracking with signal-based UI updates.
## Provides centralized score management for orbs, UI, and save systems.
## Registered as autoload singleton "ScoreManager" in project.godot

## Emitted when current score changes
signal score_changed(new_score: int)

## Emitted when high score changes
signal high_score_changed(new_high: int)

## Current score (private)
var _current_score: int = 0

## High score (private)
var _high_score: int = 0


## Get the current score
func get_score() -> int:
	return _current_score


## Get the high score
func get_high_score() -> int:
	return _high_score


## Add to current score. Also updates high score if beaten.
## Returns the new current score.
func add_score(amount: int) -> int:
	_current_score += amount
	score_changed.emit(_current_score)

	if _current_score > _high_score:
		_high_score = _current_score
		high_score_changed.emit(_high_score)

	return _current_score


## Reset current score to zero. High score is preserved.
func reset_score() -> void:
	_current_score = 0
	score_changed.emit(_current_score)


## Set high score directly (for save system integration)
func set_high_score(value: int) -> void:
	_high_score = value


## Set current score directly (for testing purposes only)
func set_score(value: int) -> void:
	_current_score = value
	score_changed.emit(_current_score)
