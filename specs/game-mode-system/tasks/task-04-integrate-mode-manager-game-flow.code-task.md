---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Integrate ModeManager with Game Flow

## Description
Connect ModeManager to the existing game flow by hooking into world_builder.gd for mode initialization, subscribing to GameOverEvent for mode termination, and handling ReplayEvent for mode restart.

## Background
The game already has a well-defined flow: load_world() starts gameplay, ball.gd emits GameOverEvent on drop, and world_builder handles replay. ModeManager needs to integrate at these points without breaking existing behavior. The integration follows the existing event system pattern.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 5 Data Flow)

**Additional References:**
- specs/game-mode-system/context.md (Integration Points)
- specs/game-mode-system/plan.md (Step 4 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/world_builder.gd`:
   - Call `ModeManager.start_mode_if_none()` in `load_world()` or default to endless
   - Subscribe to ModeManager.mode_ended for game over handling
2. Modify ModeManager to subscribe to:
   - `GameOverEvent` -> call `end_mode({"win": false})`
   - `ReplayEvent` -> restart current mode
3. Ensure GameState.current_mode is set to PLAYING when mode starts
4. Ensure GameState.current_mode is set to GAME_OVER when mode ends

## Dependencies
- Task 02: ModeManager Singleton Core (needs ModeManager)
- Task 03: ModeBase and EndlessMode (needs mode implementation)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/integration/test_mode_transitions.gd` with test cases:
     - test_game_start_initializes_mode
     - test_game_over_ends_mode
     - test_replay_restarts_mode
     - test_mode_switch
2. **Implement minimal code to pass**
   - Add ModeManager integration to world_builder.gd
   - Add event subscriptions to ModeManager._ready()
   - Handle mode lifecycle with GameState coordination
3. **Refactor while keeping tests green**
   - Ensure no regressions in existing gameplay
   - Verify proper cleanup on mode end

## Acceptance Criteria

1. **Game Start Initializes Mode**
   - Given the game scene loads
   - When load_world() is called
   - Then ModeManager.current_mode is not null (defaults to endless)

2. **Game Over Ends Mode**
   - Given a mode is active
   - When GameOverEvent is invoked
   - Then mode_ended signal is emitted with win=false

3. **Replay Restarts Mode**
   - Given a mode ended with game over
   - When ReplayEvent is invoked
   - Then the same mode is restarted with score reset

4. **Mode Switch Works**
   - Given endless mode is active
   - When calling start_mode("time_attack") then start_mode("endless")
   - Then only endless mode is active

5. **Integration Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests in test_mode_transitions.gd pass

6. **No Regressions**
   - Given the integration is complete
   - When running existing tests
   - Then all existing tests still pass

7. **Demo Works**
   - Given the game is launched
   - When playing from menu
   - Then mode is active; when ball drops, mode ends correctly

## Metadata
- **Complexity**: Medium
- **Labels**: integration, events, lifecycle
- **Required Skills**: GDScript, Godot Signals, Event Systems
