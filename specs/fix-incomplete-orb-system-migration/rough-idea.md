# Fix Incomplete Orb System Migration

## Context
A previous Ralph session implemented a refactoring plan to create a unified orb system, but the migration was left incomplete, causing the game to fail with class name conflicts.

## Current Problem
Two scripts declare `class_name HalfSolidOrb`, causing GDScript errors:

1. **OLD (in use):** `scripts/half_solid_orb.gd` - extends Node2D, used by `scenes/half_solid_orb.tscn`
2. **NEW (unused):** `scripts/entities/orb/half_solid_orb.gd` - extends Orb base class, NOT used by any scene

The new orb system in `scripts/entities/orb/` was created but never integrated:
- `scripts/entities/orb/orb.gd` - base Orb class
- `scripts/entities/orb/orb_definition.gd` - OrbDefinition resource
- `scripts/entities/orb/orb_registry.gd` - OrbRegistry static class
- `scripts/entities/orb/half_solid_orb.gd` - HalfSolidOrb subclass

None of these are referenced by any `.tscn` scene files.

## Current Working Code (DO NOT DELETE)
These files are in active use and must remain functional:
- `scripts/half_solid_orb.gd` - has `class_name HalfSolidOrb`
- `scripts/blue_orb.gd` - has `class_name BlueOrb`
- `scripts/red_orb.gd` - has `class_name RedOrb`
- `scripts/generic_orb.gd` - references `HalfSolidOrb` type hint
- `scenes/half_solid_orb.tscn` - uses `scripts/half_solid_orb.gd`

## Required Fix: Revert Incomplete Refactor

Delete the entire `scripts/entities/orb/` directory to remove the conflicting new classes. This will:
1. Eliminate the duplicate `class_name HalfSolidOrb` conflict
2. Restore the game to a working state with the original orb implementation
3. Keep all existing tests and functionality intact
