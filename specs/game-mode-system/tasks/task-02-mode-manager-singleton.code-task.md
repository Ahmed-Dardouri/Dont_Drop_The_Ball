---
status: completed
created: 2026-03-11
started: 2026-03-11
completed: 2026-03-11
---
# Task: ModeManager Singleton Core

## Description
Create the `ModeManager` autoload singleton that orchestrates mode lifecycle. This is the central hub for starting modes, ending modes, and managing high scores.

## Background
The ModeManager follows the existing singleton pattern used by `GameState` and `ScoreManager`. It loads ModeConfig resources, instantiates mode implementations, and emits signals for UI updates. It maintains a clear separation from GameState which handles game STATE (menu/playing/paused) while ModeManager handles game PLAY MODE (endless/time_attack/etc).

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 3.1 ModeManager)

**Additional References:**
- specs/game-mode-system/context.md (Critical Decision: GameState vs ModeManager)
- specs/game-mode-system/plan.md (Step 2 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/core/mode_manager.gd` extending Node with class_name ModeManager
2. Implement signals: mode_started, mode_ended, metric_updated
3. Implement core methods:
   - `start_mode(mode_id: String) -> void`
   - `end_mode(result: Dictionary) -> void`
   - `get_mode_config(mode_id: String) -> ModeConfig`
   - `get_current_metric() -> Dictionary`
   - `get_high_score(mode_id: String) -> int`
   - `set_high_score(mode_id: String, score: int) -> void`
4. Load available modes from resources/modes/ directory
5. Register as autoload in project.godot

## Dependencies
- Task 01: Mode Data Foundation (requires ModeConfig class)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_mode_manager.gd` with test cases:
     - test_initial_state
     - test_start_mode
     - test_start_invalid_mode
     - test_end_mode
     - test_get_mode_config
     - test_get_mode_config_invalid
2. **Implement minimal code to pass**
   - Create ModeManager with basic lifecycle methods
   - Load mode configs from resources/modes/
   - Register in project.godot
3. **Refactor while keeping tests green**
   - Ensure proper signal emission
   - Handle edge cases gracefully

## Acceptance Criteria

1. **Initial State**
   - Given a fresh ModeManager instance
   - When checking current_mode
   - Then it equals null

2. **Start Mode**
   - Given ModeManager is initialized
   - When calling start_mode("endless")
   - Then current_mode.mode_id equals "endless" and mode_started signal is emitted

3. **Invalid Mode Handling**
   - Given ModeManager is initialized
   - When calling start_mode("nonexistent")
   - Then a warning is logged and no state change occurs

4. **End Mode**
   - Given a mode is started
   - When calling end_mode({"win": false})
   - Then current_mode equals null and mode_ended signal is emitted

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 6 tests in test_mode_manager.gd pass

6. **Autoload Registered**
   - Given project.godot is updated
   - When running the game
   - Then ModeManager is accessible globally

## Metadata
- **Complexity**: Medium
- **Labels**: core, singleton, lifecycle
- **Required Skills**: GDScript, Godot Autoloads, Signals
