---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: High Score Persistence

## Description
Implement mode-specific high score tracking with persistence. Each mode maintains its own high score, saved to the SavedGame resource and loaded on game start.

## Background
The game currently tracks a single high score (`SavedGame.pb`). This task extends the save system to track high scores per mode. ModeManager handles getting/setting scores, and game_over_screen.gd updates the appropriate high score based on the current mode.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 4.1 SavedGame Extension)

**Additional References:**
- specs/game-mode-system/context.md (Integration Points 5 and 6)
- specs/game-mode-system/plan.md (Step 10 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/utils/saved_game.gd`:
   - Add `@export var mode_high_scores: Dictionary = {}`
2. Extend ModeManager with high score methods:
   - `get_high_score(mode_id: String) -> int`: returns score or 0 if not set
   - `set_high_score(mode_id: String, score: int) -> void`: updates if score is higher
3. Modify `scripts/game_over_screen.gd`:
   - Use `ModeManager.get_high_score()` and `set_high_score()` for mode scores
   - Keep existing `pb` for backwards compatibility (endless mode default)
4. Handle save migration:
   - If `mode_high_scores` is missing from save file, initialize to `{}`
   - Optionally migrate existing `pb` to `mode_high_scores["endless"]`

## Dependencies
- Task 04: Integrate ModeManager with Game Flow (needs ModeManager integration)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/integration/test_mode_high_scores.gd` with test cases:
     - test_new_mode_zero_score
     - test_set_high_score
     - test_update_only_if_higher
     - test_persistence
2. **Implement minimal code to pass**
   - Extend SavedGame with mode_high_scores
   - Implement ModeManager high score methods
   - Update game_over_screen.gd
3. **Refactor while keeping tests green**
   - Ensure save migration works
   - Handle edge cases (corrupt save, etc.)

## Acceptance Criteria

1. **New Mode Zero Score**
   - Given a fresh save with no high score for "orb_hunt"
   - When calling get_high_score("orb_hunt")
   - Then it returns 0

2. **Set High Score**
   - Given a mode with no existing high score
   - When calling set_high_score("endless", 500)
   - Then SavedGame.mode_high_scores["endless"] equals 500

3. **Update Only If Higher**
   - Given a mode with existing high score of 500
   - When calling set_high_score("endless", 300)
   - Then the score remains 500 (not updated)

4. **Persistence Works**
   - Given a high score of 500 is set
   - When reloading the save file
   - Then get_high_score() returns 500

5. **Integration Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests in test_mode_high_scores.gd pass

6. **Demo Works**
   - Given a high score is achieved in Time Attack
   - When returning to mode selection
   - Then Time Attack shows the high score

## Metadata
- **Complexity**: Medium
- **Labels**: persistence, save-load, scores
- **Required Skills**: GDScript, Godot Resources, Serialization
