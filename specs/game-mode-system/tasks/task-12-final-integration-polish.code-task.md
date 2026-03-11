---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Final Integration and Polish

## Description
Complete final integration testing, polish UI elements, add mode icons, verify all systems work together, and run the full E2E scenario. This is the final verification step before the game mode system is complete.

## Background
All individual components are implemented. This task ensures they work together seamlessly, adds final polish (icons, descriptions), and verifies the complete E2E scenario works without errors.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Full system)

**Additional References:**
- specs/game-mode-system/plan.md (Step 12 details, E2E Scenario)
- specs/game-mode-system/context.md (All integration points)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Add mode icons to `resources/modes/` for each mode
2. Update mode configs with final descriptions and icons
3. Run complete test suite:
   - `./devscripts/test.sh` - all unit + integration tests
   - `./devscripts/smoke_test.sh` - runtime validation
4. Execute E2E scenario manually:
   - Launch game
   - Navigate to mode selection
   - Play each mode
   - Verify high score persistence
   - Verify replay works
5. Fix any issues found during testing
6. Clean up any debug code or temporary files
7. Verify no regressions in existing gameplay

## Dependencies
- Task 05: Mode Selection UI (UI complete)
- Task 06: Time Attack Mode (mode complete)
- Task 07: Orb Hunt Mode (mode complete)
- Task 08: Survival Mode (mode complete)
- Task 09: Mode-Specific Orb Pools (spawning complete)
- Task 10: High Score Persistence (scores complete)
- Task 11: HUD Mode Display (UI complete)

## Implementation Approach
1. **Verification Phase**
   - Run all tests, note any failures
   - Execute E2E scenario, document issues
2. **Polish Phase**
   - Add icons to mode configs
   - Finalize descriptions
   - Clean up code
3. **Fix Phase**
   - Address any test failures
   - Fix E2E issues
   - Handle edge cases

## Acceptance Criteria

1. **All Tests Pass**
   - Given the full implementation is complete
   - When running ./devscripts/test.sh
   - Then all tests pass with exit code 0

2. **Smoke Test Passes**
   - Given the full implementation is complete
   - When running ./devscripts/smoke_test.sh
   - Then it passes with exit code 0

3. **E2E Scenario Complete**
   - Given the game is launched
   - When executing the E2E scenario (Time Attack playthrough)
   - Then all 9 steps complete successfully

4. **All Modes Playable**
   - Given each mode is selected
   - When playing each mode
   - Then each mode has correct behavior (win/lose conditions, metrics)

5. **High Scores Persist**
   - Given a high score is achieved
   - When restarting the game
   - Then high scores are preserved

6. **No Regressions**
   - Given all mode system changes
   - When playing the original endless mode
   - Then gameplay is unchanged from before

7. **Mode Icons Present**
   - Given mode selection screen
   - When viewing available modes
   - Then each mode has an appropriate icon

## Metadata
- **Complexity**: Medium
- **Labels**: integration, testing, polish
- **Required Skills**: GDScript, Testing, QA
