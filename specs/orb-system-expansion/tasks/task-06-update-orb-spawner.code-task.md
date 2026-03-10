---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Update OrbSpawner

## Description
Update the OrbSpawner to use the new OrbSpawnEntry resources with weighted random selection and max orbs limit enforcement.

## Background
The current OrbSpawner uses a simple array of OrbProps with random selection. The new system needs weighted selection based on spawn weights and rarity tiers, plus enforcement of a maximum orbs limit.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/orb_spawn_entry.gd` extending Resource:
   - `@export var orb_data: OrbData`
   - `@export var weight: float = 1.0`
2. Update `scripts/orb_spawner.gd`:
   - Replace `OrbProps` array with `OrbSpawnEntry` array
   - Replace `generic_orb_scene` with new unified `orb_scene`
   - Implement `_select_orb_data() -> OrbData` with weighted selection
   - Add `@export var max_orbs: int = 10`
   - Check current orb count before spawning
3. Weighted selection algorithm:
   - Sum all weights
   - Pick random value 0 to total
   - Iterate entries, subtracting weight until selection found

## Dependencies
- Task 01: OrbData Resource Class
- Task 05: Unified Orb Scene and Script

## Implementation Approach
1. **TDD: Write failing test first**
   - Create/update `tests/unit/test_orb_spawner.gd`
   - Test weighted selection distribution
   - Test max orbs limit enforcement
2. **Implement minimal code to pass**
   - Create OrbSpawnEntry resource
   - Update OrbSpawner with new logic
3. **Refactor while keeping tests green**
   - Ensure spawn timing unchanged

## Acceptance Criteria

1. **Weighted Selection**
   - Given spawn entries with weights 100 and 50
   - When selection runs 1000 times
   - Then ratio is approximately 2:1

2. **Max Orbs Limit**
   - Given max_orbs = 3
   - When spawn is called 5 times
   - Then only 3 orbs exist in scene

3. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_orb_spawner.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: spawner, weighted-selection
- **Required Skills**: GDScript, Godot Resources
