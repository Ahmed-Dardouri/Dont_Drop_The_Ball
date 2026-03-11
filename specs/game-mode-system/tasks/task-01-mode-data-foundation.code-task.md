---
status: completed
created: 2026-03-11
started: 2026-03-11
completed: 2026-03-11
---
# Task: Mode Data Foundation

## Description
Create the `ModeConfig` resource class and the first mode configuration file (`endless_mode.tres`). This establishes the data foundation that all game modes will use for configuration.

## Background
The game mode system uses Godot's Resource pattern for editor-configurable mode properties. This matches the existing `OrbData` pattern in the codebase. The ModeConfig resource defines properties like mode ID, display name, description, spawn settings, and references to the mode implementation script.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 3.2 ModeConfig)

**Additional References:**
- specs/game-mode-system/context.md (Resource pattern)
- specs/game-mode-system/plan.md (Step 1 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/mode_config.gd` with the ModeConfig class extending Resource
2. Include all @export properties: mode_id, display_name, description, icon, implementation, orb_pool, spawn_interval, max_orbs, hud_metric, has_win
3. Add an `is_valid()` method that validates required fields
4. Create `resources/modes/` directory
5. Create `resources/modes/endless_mode.tres` with basic endless mode configuration

## Dependencies
- None (this is the foundation step)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_mode_config.gd` with test cases:
     - test_default_values
     - test_resource_load
     - test_validation_valid
     - test_validation_empty_id
2. **Implement minimal code to pass**
   - Create ModeConfig class with all properties
   - Create endless_mode.tres resource file
3. **Refactor while keeping tests green**
   - Ensure property types are correct
   - Verify resource loads correctly

## Acceptance Criteria

1. **ModeConfig Class Created**
   - Given the mode system needs configuration data
   - When creating a new ModeConfig
   - Then it has all required @export properties with correct types

2. **Validation Works**
   - Given a ModeConfig with mode_id="endless" and display_name="Endless"
   - When calling is_valid()
   - Then it returns true

3. **Empty ID Invalid**
   - Given a ModeConfig with mode_id=""
   - When calling is_valid()
   - Then it returns false

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests in test_mode_config.gd pass

5. **Demo Works**
   - Given the resource file exists
   - When loading from "res://resources/modes/endless_mode.tres"
   - Then it returns a valid ModeConfig resource with correct properties

## Metadata
- **Complexity**: Low
- **Labels**: foundation, data, resource
- **Required Skills**: GDScript, Godot Resources
