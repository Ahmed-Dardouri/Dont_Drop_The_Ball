---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Modify OrbSpawner for Bridge Integration

## Description
Update OrbSpawner to support spawning both OrbProps orbs (existing) and OrbData orbs (new) via a combined weighted pool.

## Background
The spawner currently only uses OrbProps array. We need to add OrbData support while preserving backward compatibility. The new system uses weighted selection based on OrbRarity and includes a debug mechanism for testing specific orb types.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.3 - OrbSpawner)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 9)
- scripts/orb_spawner.gd (current implementation)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Modify `scripts/orb_spawner.gd`:
   - Add `@export var orb_data_array: Array[OrbData] = []`
   - Add `@export var debug_force_orb_type: String = ""`
2. Modify `_spawn_from_props()` to:
   - Build combined pool of OrbProps and OrbData entries
   - Apply rarity weights to OrbData entries
   - Handle debug_force_orb_type override
   - Use OrbAdapter for OrbData spawns
3. Add `_get_rarity_weight(rarity: OrbRarity) -> int`:
   - COMMON: 100
   - UNCOMMON: 40
   - RARE: 10
4. Add `_weighted_select(pool: Array) -> Dictionary`

## Dependencies
- task-08-orb-adapter (requires OrbAdapter.create_orb_from_data)

## Implementation Approach
1. TDD: Write test_spawns_orb_props_orbs_unchanged
2. TDD: Write test_spawns_orb_data_orbs_via_adapter
3. TDD: Write test_rarity_weighting_applied
4. TDD: Write test_debug_force_spawn_specific_type
5. Implement changes to pass all tests

## Acceptance Criteria

1. **OrbProps Orbs Spawn Unchanged**
   - Given orb_data_array is empty and orb_props has entries
   - When _spawn_from_props() is called
   - Then existing OrbProps spawn logic works unchanged

2. **OrbData Orbs Spawn via Adapter**
   - Given orb_props is empty and orb_data_array has entries
   - When _spawn_from_props() is called
   - Then OrbAdapter.create_orb_from_data() is used
   - And a GenericOrb with OrbData is returned

3. **Rarity Weighting Applied**
   - Given orb_data_array has 1 COMMON and 1 RARE orb
   - When many spawns occur
   - Then COMMON orb spawns ~10x more often than RARE

4. **Debug Force Spawn**
   - Given debug_force_orb_type = "BurstOrb"
   - And orb_data_array contains BurstOrb
   - When _spawn_from_props() is called
   - Then BurstOrb is always returned

5. **Empty Pool Handled**
   - Given both orb_props and orb_data_array are empty
   - When _spawn_from_props() is called
   - Then null is returned without error

6. **Integration Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests in test_orb_spawner_bridge.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: spawner, integration, weighted-selection
- **Required Skills**: GDScript, arrays, weighted random selection
