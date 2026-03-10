---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Create OrbAdapter Utility

## Description
Create the OrbAdapter utility class that bridges OrbData to the spawn system by creating configured GenericOrb instances.

## Background
The OrbSpawner needs a way to instantiate GenericOrb scenes from OrbData resources. OrbAdapter provides a static factory method that creates a GenericOrb and configures it with OrbData. This is the essential bridge between the new OrbData system and the existing spawn infrastructure.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.1 - OrbAdapter)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 1)
- scripts/generic_orb.gd (set_orb_data method - already implemented)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/utils/orb_adapter.gd`
2. Define `class_name OrbAdapter`
3. Implement static method:
   ```gdscript
   static func create_orb_from_data(generic_orb_scene: PackedScene, orb_data: OrbData) -> GenericOrb
   ```
4. The method must:
   - Return null if generic_orb_scene is null
   - Return null if orb_data is null
   - Instantiate generic_orb_scene
   - Call set_orb_data(orb_data) on the instance
   - Add the orb to the "orbs" group
   - Return the configured GenericOrb

## Dependencies
- None (GenericOrb.set_orb_data already exists and is tested)

## Implementation Approach
1. TDD: Write test_create_orb_from_data_returns_generic_orb
2. TDD: Write test_created_orb_has_orb_data_set
3. TDD: Write test_null_data_returns_null
4. TDD: Write test_created_orb_in_orbs_group
5. Implement OrbAdapter to pass all tests

## Acceptance Criteria

1. **Returns GenericOrb**
   - Given a valid PackedScene and OrbData
   - When create_orb_from_data() is called
   - Then a GenericOrb instance is returned

2. **OrbData Set Correctly**
   - Given a valid OrbData with display_name = "Test Orb"
   - When create_orb_from_data() is called
   - Then the returned GenericOrb has get_orb_data() returning the same OrbData

3. **Null Safety - Null Scene**
   - Given null generic_orb_scene
   - When create_orb_from_data() is called
   - Then null is returned

4. **Null Safety - Null Data**
   - Given null orb_data
   - When create_orb_from_data() is called
   - Then null is returned

5. **Added to Orbs Group**
   - Given create_orb_from_data() creates an orb
   - When checking the orb's groups
   - Then "orbs" group is present

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running ./devscripts/test.sh
   - Then all tests in test_orb_adapter.gd pass

## Metadata
- **Complexity**: Low
- **Labels**: adapter, bridge, utility, mvp
- **Required Skills**: GDScript static methods, PackedScene instantiation
