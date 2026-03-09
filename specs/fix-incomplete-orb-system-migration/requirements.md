# Requirements: Fix Incomplete Orb System Migration

## Problem Statement
Two scripts declare `class_name HalfSolidOrb`, causing GDScript errors that prevent the game from running.

## Solution
Delete the unused new orb system files to eliminate the class name conflict.

## Files to DELETE
### Source files (scripts/entities/orb/)
- `scripts/entities/orb/orb.gd`
- `scripts/entities/orb/orb_definition.gd`
- `scripts/entities/orb/orb_registry.gd`
- `scripts/entities/orb/half_solid_orb.gd`

### Test files (if they exist)
- `tests/unit/test_orb.gd`
- `tests/unit/test_half_solid_orb.gd`
- `tests/unit/test_orb_definition.gd`
- `tests/unit/test_orb_registry.gd`
- `tests/integration/test_orb_collection_integration.gd`

## Files to PRESERVE (do not modify)
- `scripts/half_solid_orb.gd` - original HalfSolidOrb class
- `scripts/blue_orb.gd`
- `scripts/red_orb.gd`
- `scripts/generic_orb.gd`
- All scene files in `scenes/`
- `tests/unit/test_orb_scoring.gd` - existing test
- `tests/unit/test_orb_properties.gd` - existing test

## Success Criteria
1. No GDScript errors on project load
2. `./devscripts/test.sh` exits with code 0
3. Game launches and plays correctly

## Scope
- IN SCOPE: Delete specified files, verify tests pass
- OUT OF SCOPE: Any refactoring, improvements, or new features

## Edge Cases
- Test files may not exist - check before deleting
- The `scripts/entities/` directory should be removed if empty after deleting `orb/`
