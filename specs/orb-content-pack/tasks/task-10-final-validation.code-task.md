---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Final Validation

## Description
Run the complete test suite and perform manual verification to ensure all 8 orb types are fully functional and no existing gameplay is broken. This is the final quality gate before the orb content pack is considered complete.

## Background
All implementation tasks (1-9) must be completed before this task. This task validates the entire orb content pack implementation through automated tests and provides manual verification steps for in-game testing.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 10 - Manual Verification Steps)
- Plan: specs/orb-content-pack/plan.md (Step 10)

**Additional References:**
- All previous task implementations
- ./devscripts/test.sh (test runner)

## Technical Requirements
1. Run `./devscripts/test.sh` and ensure it exits 0
2. Verify all new unit tests pass (25+ tests)
3. Verify all existing tests still pass (no regressions)
4. Document manual verification steps for each orb type
5. Confirm all 8 orb types are spawnable and functional in-game

## Dependencies
- Task 1: Player Group Fix
- Task 2: ScoreBehavior
- Task 3: TimedModifierBehavior
- Task 4: ChainReactionBehavior
- Task 5: LineClearBehavior
- Task 6: MovementBehavior
- Task 7: StickyHeadBehavior + Ball Integration
- Task 8: Orb Data Resources
- Task 9: Spawn System Integration

## Implementation Approach
1. **Run automated tests**
   - Execute `./devscripts/test.sh`
   - Verify exit code is 0
   - Check test output for any failures
2. **Fix any issues**
   - If tests fail, identify and fix root causes
   - Re-run tests until all pass
3. **Document manual verification**
   - Create clear steps for in-game testing
   - List expected behavior for each orb type

## Acceptance Criteria

1. **Test Suite Passes**
   - Given all implementations are complete
   - When running `./devscripts/test.sh`
   - Then the script exits 0

2. **All New Tests Pass**
   - Given the test suite runs
   - When checking test results
   - Then all 25+ new unit tests pass

3. **No Regressions**
   - Given the test suite runs
   - When checking existing test results
   - Then all existing tests still pass

4. **Manual Verification Documented**
   - Given the task is complete
   - When reviewing documentation
   - Then clear manual verification steps exist for all 8 orb types

## Manual Verification Steps

### Burst Orb
1. Start game
2. Wait for burst orb to spawn (rare, distinct appearance)
3. Position ball to collect it
4. Verify: Nearby orbs (within ~150px) should all be collected simultaneously

### Vertical Line Orb
1. Start game
2. Wait for vertical line orb to spawn
3. Note other orbs vertically aligned with it
4. Collect it
5. Verify: All orbs with similar X coordinate are collected

### Horizontal Line Orb
1. Start game
2. Wait for horizontal line orb to spawn
3. Note other orbs horizontally aligned with it
4. Collect it
5. Verify: All orbs with similar Y coordinate are collected

### Slow Fall Orb
1. Start game
2. Collect slow fall orb
3. Verify: Ball falls noticeably slower for ~45 seconds

### Sticky Head Orb
1. Start game
2. Collect sticky head orb
3. Bounce ball off player head
4. Verify: Ball bounces with reduced vertical velocity (50% slower)
5. Effect lasts ~15-20 seconds

### Double Value Orb
1. Start game
2. Collect double value orb
3. Collect any other orb
4. Verify: Score is doubled for the next orb collected

### Combo Starter Orb
1. Start game
2. Collect combo starter orb
3. Quickly collect more orbs
4. Verify: Combo counter increases
5. Window lasts ~10 seconds

### Drifter Orb
1. Start game
2. Find drifter orb (moves left-right)
3. Verify: Orb oscillates horizontally in sine wave pattern
4. Predict its position and collect it

## Metadata
- **Complexity**: Low
- **Labels**: validation, testing, manual-verification, quality-gate
- **Required Skills**: Testing, Godot gameplay, documentation
