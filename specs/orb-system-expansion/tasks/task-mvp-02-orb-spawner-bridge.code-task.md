---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Modify OrbSpawner for Bridge Integration

## Description
Update OrbSpawner to support spawning both OrbProps orbs (existing) and OrbData orbs (new) via a combined pool with simple random selection.

## Background
The spawner currently only uses OrbProps array. We need to add OrbData support while preserving backward compatibility. For the minimum viable integration, we use simple random selection from a combined pool (no weighted rarity - that can be added later).

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.3 - OrbSpawner)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 2)
- scripts/orb_spawner.gd (current implementation)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/orb_spawner.gd`:
   - Add `@export var orb_data_array: Array[OrbData] = []`
   - Add `@export var debug_force_orb_type: String = ""`
2. Modify `_spawn_from_props()` to:
   - Build combined pool of OrbProps and OrbData entries
   - Handle debug_force_orb_type override (exact match on display_name)
   - Use OrbAdapter for OrbData spawns
   - Use existing create_orb_copy() for OrbProps spawns

## Dependencies
- task-mvp-01-orb-adapter (requires OrbAdapter.create_orb_from_data)

## Implementation Approach
1. TDD: Write test_orb_data_array_export_exists
2. TDD: Write test_combined_pool_includes_orb_data
3. TDD: Write test_debug_force_orb_type_overrides_selection
4. TDD: Write test_empty_pool_returns_null
5. TDD: Write test_orb_props_path_unchanged
6. Implement changes to pass all tests

## Acceptance Criteria

1. **OrbProps Orbs Spawn Unchanged**
   - Given orb_data_array is empty and orb_props has entries
   - When _spawn_from_props() is called
   - Then existing OrbProps spawn logic works unchanged
   - And create_orb_copy() is called

2. **OrbData Orbs Spawn via Adapter**
   - Given orb_props is empty and orb_data_array has entries
   - When _spawn_from_props() is called
   - Then OrbAdapter.create_orb_from_data() is used
   - And a GenericOrb with OrbData is returned

3. **Combined Pool Selection**
   - Given both orb_props and orb_data_array have entries
   - When _spawn_from_props() is called multiple times
   - Then both OrbProps and OrbData orbs can be selected

4. **Debug Force Spawn**
   - Given debug_force_orb_type = "Test Orb"
   - And orb_data_array contains an OrbData with display_name = "Test Orb"
   - When _spawn_from_props() is called
   - Then that specific orb is always returned

5. **Debug Force Not Found**
   - Given debug_force_orb_type = "NonExistent"
   - And no matching orb in orb_data_array
   - When _spawn_from_props() is called
   - Then null is returned

6. **Empty Pool Handled**
   - Given both orb_props and orb_data_array are empty
   - When _spawn_from_props() is called
   - Then null is returned without error

7. **Unit Tests Pass**
   - Given the implementation is complete
   - When running ./devscripts/test.sh
   - Then all tests in test_orb_spawner_orb_data.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: spawner, integration, mvp
- **Required Skills**: GDScript, arrays, random selection
