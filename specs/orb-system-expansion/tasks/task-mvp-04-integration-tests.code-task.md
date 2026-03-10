---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Integration Tests for Bridge

## Description
Write integration tests that verify the complete bridge flow from OrbSpawner selection to orb instantiation and collection.

## Background
Unit tests cover individual components. Integration tests verify that:
1. OrbSpawner can select OrbData entries from combined pool
2. OrbAdapter creates working GenericOrb instances
3. Created orbs have correct OrbData and can be collected

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 6 - Testing Strategy)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 4)
- tests/unit/ directory (existing test patterns)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `tests/integration/test_orb_spawner_bridge.gd`
2. Test cases:
   - `test_spawner_creates_orb_props_orb`: Verify OrbProps path still works
   - `test_spawner_creates_orb_data_orb`: Verify OrbData path works via adapter
   - `test_debug_force_selects_correct_orb`: Verify debug override
   - `test_orb_data_orb_collectible`: Verify created orb can be collected

## Dependencies
- task-mvp-01-orb-adapter
- task-mvp-02-orb-spawner-bridge
- task-mvp-03-orb-resources (for test data)

## Implementation Approach
1. Create integration test file
2. Set up test spawner with both OrbProps and OrbData
3. Test selection from combined pool
4. Test created orb has correct properties
5. Test collection flow works

## Acceptance Criteria

1. **OrbProps Path Works**
   - Given a spawner with only OrbProps entries
   - When _spawn_from_props() is called
   - Then an orb is created via create_orb_copy()
   - And the orb is a valid Node

2. **OrbData Path Works**
   - Given a spawner with only OrbData entries
   - When _spawn_from_props() is called
   - Then an orb is created via OrbAdapter
   - And the orb has get_orb_data() returning the correct OrbData

3. **Debug Force Works**
   - Given debug_force_orb_type = "Test Orb"
   - And orb_data_array contains "Test Orb"
   - When _spawn_from_props() is called
   - Then exactly that orb is returned
   - And other orbs are never selected

4. **Created Orb Is Collectible**
   - Given an orb created from OrbData
   - When on_orb_collected() is called
   - Then behaviors are executed
   - And AddScoreEvent is invoked with correct score

5. **Integration Tests Pass**
   - Given all implementations are complete
   - When running ./devscripts/test.sh
   - Then all integration tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: testing, integration, mvp
- **Required Skills**: GUT testing framework, Godot scene manipulation
