---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Final Validation

## Description
Perform final validation of the complete refactor by running all automated tests and manual E2E verification to ensure gameplay is preserved.

## Background
Before marking the refactor complete, comprehensive validation ensures all components work together and the game plays identically to the pre-refactor behavior.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 7: Testing Strategy)

**Additional References:**
- specs/ai-refactor-prep/plan.md (Step 17)
- README_FOR_AGENT.md (validation requirements)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Run `./devscripts/import.sh` - verify no import errors
2. Run `./devscripts/smoke_test.sh` - verify game launches
3. Run `./devscripts/test.sh` - verify all tests pass (exit code 0)
4. Manual E2E validation:
   - Game launches without errors
   - Player movement works (left/right/jump)
   - Ball bounces correctly
   - All orb types spawn and collect correctly
   - Blue orbs: 2 points
   - Red orbs: 3 points
   - Half-solid orbs: bounce first, 8 points on second hit
   - Pause/resume works
   - Game over triggers on ground hit
   - Score displays correctly

## Dependencies
- All previous tasks (entire refactor must be complete)

## Implementation Approach
1. Run all automated validation scripts
2. Fix any failing tests or errors
3. Perform manual E2E playtest
4. Document any issues found
5. Confirm all validation criteria pass

## Acceptance Criteria

1. **Import Script Passes**
   - Given all code is implemented
   - When running `./devscripts/import.sh`
   - Then exit code is 0 and no errors

2. **Smoke Test Passes**
   - Given all code is implemented
   - When running `./devscripts/smoke_test.sh`
   - Then exit code is 0

3. **All Tests Pass**
   - Given all code is implemented
   - When running `./devscripts/test.sh`
   - Then exit code is 0

4. **Player Movement Works**
   - Given game is running
   - When pressing A/D or arrow keys
   - Then player moves left/right

5. **Jump Works**
   - Given game is running and player is grounded
   - When pressing Space or W
   - Then player jumps

6. **Ball Bounces Correctly**
   - Given game is running
   - When player collides with ball
   - Then ball bounces realistically

7. **Orbs Spawn and Collect**
   - Given game is running
   - When time passes
   - Then blue, red, and half-solid orbs spawn
   - And collecting adds correct score

8. **Pause/Resume Works**
   - Given game is running
   - When pressing Escape or P
   - Then game pauses
   - When pressing again
   - Then game resumes

9. **Game Over Works**
   - Given game is running
   - When ball hits ground
   - Then game over screen appears with correct score

10. **No Console Errors**
    - Given the game is running
    - When playing a complete session
    - Then no errors or warnings appear in console

## Metadata
- **Complexity**: Low (verification only)
- **Labels**: validation, e2e, testing
- **Required Skills**: GDScript, game testing
