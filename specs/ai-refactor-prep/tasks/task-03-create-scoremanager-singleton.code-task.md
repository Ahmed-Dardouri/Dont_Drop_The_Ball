---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create ScoreManager Singleton

## Description
Create the `ScoreManager` autoload singleton that tracks current score and high score with signal-based notifications for UI updates.

## Background
Score tracking is currently scattered. This singleton provides centralized score management that can be used by orbs, UI, and save systems. It emits signals when scores change, enabling reactive UI updates.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.2: ScoreManager Singleton)

**Additional References:**
- specs/ai-refactor-prep/context.md (New Autoloads to Add)
- specs/ai-refactor-prep/plan.md (Step 3)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/core/score_manager.gd` with class_name ScoreManager
2. Implement private `_current_score` and `_high_score` variables
3. Implement `get_score() -> int` getter
4. Implement `get_high_score() -> int` getter
5. Implement `add_score(amount: int) -> int` that updates both current and high score
6. Implement `reset_score()` that zeros current score only
7. Implement `set_high_score(value: int)` for save system integration
8. Emit `score_changed` signal when score changes
9. Emit `high_score_changed` signal when high score changes
10. Register as autoload in `project.godot`

## Dependencies
- None (independent of other tasks)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_score_manager.gd` first
2. Implement `scripts/core/score_manager.gd`
3. Add autoload entry to `project.godot`: `ScoreManager="*res://scripts/core/score_manager.gd"`
4. Run tests and verify they pass

## Acceptance Criteria

1. **Initial Score is Zero**
   - Given a fresh ScoreManager
   - When calling `get_score()`
   - Then the result is 0

2. **Add Score Increases**
   - Given current score is 0
   - When calling `add_score(10)`
   - Then `get_score()` returns 10
   - And `add_score()` returns 10

3. **Score Accumulates**
   - Given current score is 5
   - When calling `add_score(3)`
   - Then `get_score()` returns 8

4. **High Score Updates When Beaten**
   - Given high score is 0
   - When calling `add_score(100)`
   - Then `get_high_score()` returns 100

5. **High Score Not Updated When Lower**
   - Given high score is 200
   - When calling `add_score(50)`
   - Then `get_high_score()` remains 200

6. **Reset Clears Current Only**
   - Given current score is 100 and high score is 100
   - When calling `reset_score()`
   - Then `get_score()` returns 0
   - And `get_high_score()` remains 100

7. **Score Signal Emits**
   - Given a signal handler connected to `score_changed`
   - When calling `add_score(42)`
   - Then the handler receives `(42)`

8. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all `test_score_manager.gd` tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: foundation, singleton, scoring, autoload
- **Required Skills**: GDScript, Godot 4.x, signals
