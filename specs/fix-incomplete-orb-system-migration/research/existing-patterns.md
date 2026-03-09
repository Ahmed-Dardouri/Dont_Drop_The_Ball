# Research: Existing Patterns

## Files to Delete Verification

All 4 source files in `scripts/entities/orb/` confirmed to exist:
- `scripts/entities/orb/orb.gd` - `class_name Orb extends Node2D`
- `scripts/entities/orb/orb_definition.gd` - `class_name OrbDefinition extends Resource`
- `scripts/entities/orb/orb_registry.gd` - `class_name OrbRegistry`
- `scripts/entities/orb/half_solid_orb.gd` - `extends Orb` (no class_name, depends on Orb base)

All 5 test files confirmed to exist:
- `tests/unit/test_orb.gd`
- `tests/unit/test_orb_definition.gd`
- `tests/unit/test_orb_registry.gd`
- `tests/integration/test_orb_collection_integration.gd`

Note: `tests/unit/test_half_solid_orb.gd` does NOT exist - skip deletion.

## Integration Analysis

### No Active References
- No `.gd` files outside `scripts/entities/orb/` reference the new orb system
- No `.tscn` scene files reference `entities/orb`
- Only documentation/planning files reference these paths (historical records)

### Directory Structure
- `scripts/entities/` contains only the `orb/` subdirectory
- After deleting `orb/`, the `entities/` directory will be empty and should be removed

## Files to Preserve (Verified Working)

The following files use the original orb implementation and must NOT be modified:
- `scripts/half_solid_orb.gd` - `class_name HalfSolidOrb` (original, in use)
- `scripts/blue_orb.gd` - `class_name BlueOrb`
- `scripts/red_orb.gd` - `class_name RedOrb`
- `scripts/generic_orb.gd` - references `HalfSolidOrb` type hint
- `scripts/utils/orb_properties.gd` - `class_name OrbProps` (unrelated to new system)
- `scenes/half_solid_orb.tscn` - uses `scripts/half_solid_orb.gd`

## Test Files to Preserve
- `tests/unit/test_orb_scoring.gd` - existing test for scoring
- `tests/unit/test_orb_properties.gd` - existing test for OrbProps
