---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Final Validation

## Description
Execute final validation including automated tests and manual verification checklist to confirm the orb system expansion is complete and functional.

## Background
This is the final step that verifies all previous work is complete and the game is in a shippable state. Both automated tests and manual verification are required.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Run automated validation:
   ```bash
   ./devscripts/import.sh
   ./devscripts/test.sh
   ./devscripts/smoke_test.sh
   ```
2. Complete manual verification checklist:
   - [ ] Game boots without errors
   - [ ] All 12 orb types spawn
   - [ ] Score tracking correct
   - [ ] Effect stacking works
   - [ ] Effects expire on time
   - [ ] Effects clear on game over
   - [ ] Time slow affects game speed
   - [ ] Slow fall affects ball physics
   - [ ] Line orbs clear correctly
   - [ ] Burst orb clears radius
   - [ ] Drifter orb moves
   - [ ] Combo chain multiplies score
   - [ ] Double value works one-time
   - [ ] No console errors

## Dependencies
- All previous tasks (1-23) must be complete

## Implementation Approach
1. **Run automated tests**
   - Execute all test scripts
   - Fix any failures
2. **Manual verification**
   - Play through game
   - Check each item on checklist
3. **Document results**
   - Record any issues found
   - Fix issues and re-verify

## Acceptance Criteria

1. **Automated Tests Pass**
   - Given all code is complete
   - When running test.sh
   - Then all tests pass with exit code 0

2. **Smoke Test Passes**
   - Given all code is complete
   - When running smoke_test.sh
   - Then smoke test passes with exit code 0

3. **Manual Checklist Complete**
   - Given manual verification
   - When all items checked
   - Then all 14 checklist items pass

4. **No Console Errors**
   - Given game running
   - When playing for 5 minutes
   - Then no errors appear in console

## Metadata
- **Complexity**: Medium
- **Labels**: validation, testing, final
- **Required Skills**: GDScript, Testing, QA
