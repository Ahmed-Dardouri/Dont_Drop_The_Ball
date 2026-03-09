extends Node
## Centralized game state management with signal-based notifications.
## Provides a single source of truth for pause state and game mode.
## Registered as autoload singleton "GameState" in project.godot

## Emitted when is_paused changes
signal pause_changed(is_paused: bool)

## Emitted when current_mode changes
signal mode_changed(new_mode: Enums.GameMode)

## Current pause state
var is_paused: bool = false:
	set(value):
		if is_paused != value:
			is_paused = value
			pause_changed.emit(is_paused)

## Current game mode
var current_mode: Enums.GameMode = Enums.GameMode.MENU:
	set(value):
		if current_mode != value:
			current_mode = value
			mode_changed.emit(current_mode)


## Toggle pause state between true and false
func toggle_pause() -> void:
	is_paused = not is_paused


## Reset all state to default values
func reset() -> void:
	is_paused = false
	current_mode = Enums.GameMode.MENU
