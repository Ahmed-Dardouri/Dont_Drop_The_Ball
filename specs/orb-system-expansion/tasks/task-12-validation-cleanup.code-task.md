---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Validation & Cleanup

## Description
Run full test suite, perform manual verification of all orb types, and document the verification steps.

## Background
All implementation tasks are complete. This final task ensures everything works together and documents how to verify the new orbs in-game.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 6 - Testing Strategy)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 12)
- specs/orb-system-expansion/requirements.md (original requirements)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Run `./devscripts/test.sh` and ensure exit code 0
2. Manual verification of each orb type:
   - Set debug_force_orb_type in OrbSpawner
   - Run game
   - Verify orb spawns with correct visual
   - Collect orb and verify behavior
3. Verify existing blue/red/half-solid orbs still work
4. Document manual verification steps in final summary

## Dependencies
- All previous tasks (01-11)

## Implementation Approach
1. Run test suite, fix any failures
2. For each orb type:
   a. Set debug_force_orb_type to orb's display_name
   b. Run game
   c. Wait for orb spawn
   d. Verify visual appearance
   e. Collect orb
   f. Verify behavior executes correctly
3. Test old orbs still work (disable debug_force_orb_type)
4. Document findings

## Acceptance Criteria

1. **Test Suite Passes**
   - Given all implementation is complete
   - When running ./devscripts/test.sh
   - Then exit code is 0
   - And all tests pass

2. **All 8 Orb Types Verified**
   - For each orb type (Burst, VerticalLine, HorizontalLine, SlowFall, StickyHead, DoubleValue, ComboStarter, Drifter)
   - Given debug_force_orb_type is set to that orb
   - When game runs
   - Then orb spawns with correct visual
   - And behavior executes correctly on collection

3. **Old Orbs Still Work**
   - Given debug_force_orb_type is empty
   - When game runs
   - Then blue orbs, red orbs, and half-solid orbs spawn and work correctly

4. **Manual Verification Steps Documented**
   - Given validation is complete
   - When reviewing documentation
   - Then clear steps exist for verifying each orb type in-game

5. **No Runtime Errors**
   - Given game is running
   - When playing normally for 5+ minutes
   - Then no errors appear in console

## Metadata
- **Complexity**: Low
- **Labels**: validation, testing, documentation
- **Required Skills**: Manual testing, documentation
