---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create GameState Singleton

## Description
Create the `GameState` autoload singleton that centralizes game state management with signal-based notifications. This includes tracking pause state and current game mode.

## Background
Currently, game state is scattered across static variables (e.g., `PauseEvent.state`). This singleton provides a single source of truth with proper signal emission for state changes, enabling UI and game systems to react appropriately.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.1: GameState Singleton)

**Additional References:**
- specs/ai-refactor-prep/context.md (New Autoloads to Add)
- specs/ai-refactor-prep/plan.md (Step 2)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/core/game_state.gd` with class_name GameState
2. Implement `is_paused` property with signal emission on change
3. Implement `current_mode` property (GameMode enum) with signal emission
4. Implement `toggle_pause()` method
5. Implement `reset()` method that clears state to defaults
6. Register as autoload in `project.godot`

## Dependencies
- task-01-add-gamemode-enum (requires GameMode enum)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_game_state.gd` first
2. Create directory structure `scripts/core/`
3. Implement `scripts/core/game_state.gd`
4. Add autoload entry to `project.godot`: `GameState="*res://scripts/core/game_state.gd"`
5. Run tests and verify they pass
6. Run `./devscripts/smoke_test.sh` to verify no runtime errors

## Acceptance Criteria

1. **Initial State**
   - Given a fresh GameState
   - When accessing properties
   - Then `is_paused` is false and `current_mode` is `Enums.GameMode.MENU`

2. **Pause Toggle Works**
   - Given `is_paused` is false
   - When calling `toggle_pause()`
   - Then `is_paused` becomes true
   - When calling `toggle_pause()` again
   - Then `is_paused` becomes false

3. **Pause Signal Emits**
   - Given a signal handler connected to `pause_changed`
   - When setting `is_paused = true`
   - Then the signal handler receives `(true)`

4. **Mode Signal Emits**
   - Given a signal handler connected to `mode_changed`
   - When setting `current_mode = Enums.GameMode.PLAYING`
   - Then the signal handler receives `(Enums.GameMode.PLAYING)`

5. **Reset Clears State**
   - Given `is_paused` is true and `current_mode` is GAME_OVER
   - When calling `reset()`
   - Then `is_paused` is false and `current_mode` is MENU

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all `test_game_state.gd` tests pass

7. **Integration Works**
   - Given the autoload is registered
   - When running `./devscripts/test.sh` and `./devscripts/smoke_test.sh`
   - Then both exit with code 0

## Metadata
- **Complexity**: Medium
- **Labels**: foundation, singleton, state-management, autoload
- **Required Skills**: GDScript, Godot 4.x, signals
