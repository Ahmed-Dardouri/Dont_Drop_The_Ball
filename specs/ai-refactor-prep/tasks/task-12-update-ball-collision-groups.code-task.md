---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Update Ball Collision to Use Groups

## Description
Update ball collision handler to use group-based detection instead of hardcoded name checks for ground and half-solid orb detection.

## Background
The ball's `_on_body_entered` function currently checks `body.name == "ground_static"` and `body.name == "half_static"`. This tight coupling makes the code brittle and harder to maintain.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 3: Architecture Overview)

**Additional References:**
- specs/ai-refactor-prep/plan.md (Step 12)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/ball.gd` `_on_body_entered()` function
2. Replace `body.name == "ground_static"` with `body.is_in_group("ground")`
3. Replace `body.name == "half_static"` with `body.is_in_group("half_solid")` or type check
4. Update game over logic to use `GameState.is_paused = true` instead of local pause
5. Update score access to use `ScoreManager.get_score()`

## Dependencies
- task-02-create-gamestate-singleton (for GameState)
- task-03-create-scoremanager-singleton (for ScoreManager)
- task-11-add-groups-to-entities (for groups)

## Implementation Approach
1. Read existing `scripts/ball.gd` collision handler
2. Update name checks to group checks
3. Update game over to use GameState and ScoreManager
4. Run smoke test to verify ball behavior is preserved

## Acceptance Criteria

1. **Ground Detection via Groups**
   - Given ball collides with ground
   - When `_on_body_entered` is called with ground body
   - Then `body.is_in_group("ground")` returns true
   - And game over is triggered

2. **Half-Solid Detection via Groups**
   - Given ball collides with half-solid orb
   - When `_on_body_entered` is called
   - Then the ball bounces (velocity reduced)

3. **Game Over Uses GameState**
   - Given ball hits ground
   - When game over is triggered
   - Then `GameState.is_paused` is set to true

4. **Score Uses ScoreManager**
   - Given game over occurs
   - When game over event is emitted
   - Then it uses `ScoreManager.get_score()` for final score

5. **Existing Behavior Preserved**
   - Given the game is running
   - When ball hits ground
   - Then game over screen appears with correct score

6. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass

7. **Smoke Test Passes**
   - Given the implementation is complete
   - When running `./devscripts/smoke_test.sh`
   - Then exit code is 0

## Metadata
- **Complexity**: Medium
- **Labels**: collision, migration, groups, ball
- **Required Skills**: GDScript, Godot 4.x
