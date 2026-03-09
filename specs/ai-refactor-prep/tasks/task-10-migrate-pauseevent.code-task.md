---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Migrate PauseEvent to GameState

## Description
Modify `PauseEvent` to delegate pause state management to the GameState singleton while maintaining backward compatibility for existing code using `PauseEvent.state`.

## Background
The refactor centralizes game state in GameState, but existing code references `PauseEvent.state`. This migration step updates PauseEvent to delegate while keeping the existing API working.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.1: GameState Singleton)

**Additional References:**
- specs/ai-refactor-prep/context.md (PauseEvent Backward Compatibility)
- specs/ai-refactor-prep/plan.md (Step 10)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/events/pause_event.gd`
2. Update `static func invoke(pause: bool)` to set `GameState.is_paused`
3. Add backward-compatible `static var state` property that delegates to GameState
4. Keep existing signal invocation via Events bus

## Dependencies
- task-02-create-gamestate-singleton (requires GameState)

## Implementation Approach
1. TDD: Update `tests/unit/test_pause_state.gd` with migration tests
2. Read existing `pause_event.gd` implementation
3. Modify to delegate to GameState
4. Add static property `state` with getter/setter
5. Verify tests pass and smoke test works

## Acceptance Criteria

1. **PauseEvent Delegates to GameState**
   - Given `GameState.is_paused` is false
   - When calling `PauseEvent.invoke(true)`
   - Then `GameState.is_paused` becomes true

2. **Backward Compat State Getter**
   - Given `GameState.is_paused` is true
   - When accessing `PauseEvent.state`
   - Then result is true

3. **Backward Compat State Setter**
   - Given `GameState.is_paused` is false
   - When setting `PauseEvent.state = true`
   - Then `GameState.is_paused` becomes true

4. **Event Still Invoked**
   - Given an event listener on the Events bus
   - When calling `PauseEvent.invoke(true)`
   - Then PauseEvent is still invoked on the bus

5. **Existing Pause Functionality Preserved**
   - Given the game is running
   - When pressing pause button
   - Then game pauses correctly (verified via smoke_test.sh)

6. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all pause-related tests pass

7. **Smoke Test Passes**
   - Given the implementation is complete
   - When running `./devscripts/smoke_test.sh`
   - Then exit code is 0

## Metadata
- **Complexity**: Low-Medium
- **Labels**: migration, backward-compat, events, state
- **Required Skills**: GDScript, Godot 4.x
