---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Update OrbSpawner to Use Registry

## Description
Update `orb_spawner.gd` to use OrbRegistry for weighted random orb type selection instead of hardcoded spawning logic.

## Background
OrbSpawner currently has hardcoded orb spawning. Migrating to use OrbRegistry enables data-driven orb selection and easier addition of new orb types without modifying the spawner.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.7: OrbRegistry)

**Additional References:**
- specs/ai-refactor-prep/context.md (Existing Group Usage - orbs group)
- specs/ai-refactor-prep/plan.md (Step 15)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/orb_spawner.gd`
2. Initialize OrbRegistry in `_ready()`
3. Update spawn logic to use `OrbRegistry.get_weighted_random()`
4. Use definition's `has_physics_body` to determine orb class (Orb vs HalfSolidOrb)
5. Keep existing max_orbs check using "orbs" group
6. Apply definition to spawned orb

## Dependencies
- task-09-create-orbregistry (requires OrbRegistry)
- task-13-create-unified-orb-class (requires Orb class)
- task-14-create-halfsolid-orb-subclass (requires HalfSolidOrb)

## Implementation Approach
1. TDD: Write/update test file `tests/unit/test_orb_spawner.gd`
2. Read existing orb_spawner.gd implementation
3. Add OrbRegistry.initialize() call in _ready()
4. Update spawn function to use registry
5. Verify smoke test passes with orbs spawning correctly

## Acceptance Criteria

1. **Spawner Initializes Registry**
   - Given OrbSpawner is added to scene
   - When `_ready()` is called
   - Then `OrbRegistry._initialized` is true

2. **Spawn Uses Registry**
   - Given OrbSpawner is spawning
   - When spawn timer fires
   - Then `OrbRegistry.get_weighted_random()` is called

3. **Definition Applied to Orb**
   - Given a definition is returned from registry
   - When orb is spawned
   - Then orb.definition equals the registry definition

4. **Has Physics Body Selects Class**
   - Given definition.has_physics_body is true
   - When spawning orb
   - Then HalfSolidOrb is instantiated
   - Given definition.has_physics_body is false
   - When spawning orb
   - Then Orb is instantiated (or generic_orb scene)

5. **Max Orbs Check Preserved**
   - Given max_orbs is 5 and 5 orbs exist
   - When spawn timer fires
   - Then no new orb is spawned

6. **Orbs Spawn Correctly**
   - Given the game is running
   - When time passes
   - Then orbs of all types (blue, red, half-solid) spawn

7. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests pass

8. **Smoke Test Passes**
   - Given the implementation is complete
   - When running `./devscripts/smoke_test.sh`
   - Then exit code is 0

## Metadata
- **Complexity**: Medium
- **Labels**: orb-system, spawner, migration
- **Required Skills**: GDScript, Godot 4.x
