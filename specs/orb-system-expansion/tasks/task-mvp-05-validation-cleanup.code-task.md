---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Validation & Manual Verification

## Description
Run full test suite, perform manual in-game verification of the test orb, and document the verification steps.

## Background
All implementation tasks are complete. This final task ensures everything works together and provides clear steps for verifying the orb appears and functions in-game.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 6 - Testing Strategy)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 5)
- specs/orb-system-expansion/requirements.md (original requirements)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Run `./devscripts/test.sh` and ensure exit code 0
2. Manual verification of test orb:
   - Configure OrbSpawner with test_orb.tres
   - Set debug_force_orb_type = "Test Orb"
   - Run game
   - Verify orb spawns with correct visual (blue_ball texture)
   - Collect orb with ball
   - Verify score increases by 5
   - Verify collection sound plays
3. Verify existing blue/red/half-solid orbs still work
4. Document what was blocking runtime integration and how to verify

## Dependencies
- task-mvp-01-orb-adapter
- task-mvp-02-orb-spawner-bridge
- task-mvp-03-orb-resources
- task-mvp-04-integration-tests

## Implementation Approach
1. Run test suite, fix any failures
2. Configure OrbSpawner for test orb
3. Run game and verify test orb appears
4. Collect test orb and verify score
5. Test old orbs still work
6. Document findings in summary

## Acceptance Criteria

1. **Test Suite Passes**
   - Given all implementation is complete
   - When running ./devscripts/test.sh
   - Then exit code is 0
   - And all tests pass

2. **Test Orb Spawns**
   - Given debug_force_orb_type = "Test Orb"
   - And test_orb.tres in orb_data_array
   - When game runs
   - Then test orb spawns with blue_ball texture
   - And orb has correct collision radius

3. **Test Orb Is Collectible**
   - Given test orb has spawned
   - When ball touches the orb
   - Then orb is collected
   - And score increases by 5
   - And collection sound plays

4. **Old Orbs Still Work**
   - Given debug_force_orb_type is empty
   - When game runs
   - Then blue orbs, red orbs, and half-solid orbs spawn and work correctly

5. **No Runtime Errors**
   - Given game is running
   - When playing normally for 2+ minutes
   - Then no errors appear in console

6. **Summary Documented**
   - Given validation is complete
   - When reviewing final summary
   - Then blocking issues are clearly explained
   - And verification steps are documented

## Manual Verification Steps

**To verify test orb in-game:**

1. Open Godot editor
2. Navigate to scene containing OrbSpawner (e.g., main.tscn)
3. Select OrbSpawner node
4. In Inspector, find `orb_data_array`
5. Add `resources/orbs/test_orb.tres` to the array
6. Set `debug_force_orb_type` to "Test Orb"
7. Run game (F5)
8. Wait for orb to spawn
9. Verify orb has blue_ball texture
10. Guide ball to collect orb
11. Verify score increases by 5
12. Verify collection sound plays

**To verify old orbs still work:**

1. Clear `debug_force_orb_type` (empty string)
2. Run game (F5)
3. Verify blue, red, and half-solid orbs spawn normally
4. Verify they are collectible as before

## Metadata
- **Complexity**: Low
- **Labels**: validation, testing, documentation, mvp
- **Required Skills**: Manual testing, documentation
