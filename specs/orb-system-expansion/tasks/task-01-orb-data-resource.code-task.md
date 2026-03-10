---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Create OrbData Resource Class

## Description
Create the `OrbData` resource class that defines all orb properties including display settings, gameplay values, physics configuration, and behaviors array. This is the foundational data structure for the data-driven orb system.

## Background
The current orb system uses hardcoded scripts for each orb type (blue_orb.gd, red_orb.gd, half_solid_orb.gd). The new system uses a unified data-driven approach where orb properties are defined in Resource files. OrbData is the central data structure that holds all orb configuration.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/orb_data.gd` extending Resource
2. Define `@export` properties for:
   - Display: `display_name: String`, `texture: Texture2D`, `scale: float`
   - Gameplay: `base_score: int`, `lifespan: float`, `rarity: OrbRarity`
   - Physics: `collision_radius: float`, `is_half_solid: bool`
   - Behaviors: `behaviors: Array[OrbBehavior]`
3. Set sensible defaults for all properties
4. Follow typed variable convention (`var name: Type`)

## Dependencies
- None (this is Step 1)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_orb_data.gd`
   - Test default values (display_name="Orb", base_score=1, lifespan=30.0)
   - Test property assignment
2. **Implement minimal code to pass**
   - Create OrbData class with all @export properties
   - Set default values
3. **Refactor while keeping tests green**
   - Ensure clean code structure
   - Add class_name for type reference

## Acceptance Criteria

1. **Default Values Correct**
   - Given a new OrbData instance is created
   - When no properties are set
   - Then display_name equals "Orb", base_score equals 1, lifespan equals 30.0

2. **Property Assignment Works**
   - Given a new OrbData instance
   - When display_name is set to "Test Orb" and base_score is set to 5
   - Then display_name equals "Test Orb" and base_score equals 5

3. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_orb_data.gd pass

## Metadata
- **Complexity**: Low
- **Labels**: core, data, resource
- **Required Skills**: GDScript, Godot Resources
