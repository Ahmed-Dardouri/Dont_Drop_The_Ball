---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Delete Old Files

## Description
Remove the old orb scripts and scenes that have been replaced by the unified Orb system.

## Background
After migrating to the unified Orb scene and resource-based orb data, the old individual orb scripts and scenes are no longer needed. Removing them cleans up the codebase and ensures no accidental usage of the old system.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (see File Migration Map)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Delete the following scripts:
   - `scripts/generic_orb.gd`
   - `scripts/blue_orb.gd`
   - `scripts/red_orb.gd`
   - `scripts/half_solid_orb.gd`
   - `scripts/utils/orb_properties.gd`
2. Delete the following scenes:
   - `scenes/generic_orb.tscn`
   - `scenes/blue_orb.tscn`
   - `scenes/red_orb.tscn`
   - `scenes/half_solid_orb.tscn`
3. Verify no references to deleted files remain in the codebase
4. Ensure all tests still pass after deletion

## Dependencies
- Task 07: Migrate Existing Orbs to Resources
- All Phase 1 and Phase 2 tasks must be complete

## Implementation Approach
1. **Search for references**
   - Use grep to find any imports/references to old files
   - Update any found references
2. **Delete files**
   - Remove each old file
3. **Verify**
   - Run tests
   - Run smoke test
   - Verify game boots

## Acceptance Criteria

1. **Old Scripts Deleted**
   - Given the task is complete
   - When checking for old script files
   - Then none of the listed scripts exist

2. **Old Scenes Deleted**
   - Given the task is complete
   - When checking for old scene files
   - Then none of the listed scenes exist

3. **No References Remain**
   - Given the task is complete
   - When searching codebase for old filenames
   - Then no references found

4. **Tests Pass**
   - Given the deletion is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass

5. **Smoke Test Passes**
   - Given the deletion is complete
   - When running `./devscripts/smoke_test.sh`
   - Then smoke test passes

## Metadata
- **Complexity**: Low
- **Labels**: cleanup, migration
- **Required Skills**: File management, GDScript
