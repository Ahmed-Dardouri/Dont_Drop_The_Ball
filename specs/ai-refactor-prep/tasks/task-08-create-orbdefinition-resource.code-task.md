---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create OrbDefinition Resource

## Description
Create the `OrbDefinition` resource class that defines orb type configuration including type name, display name, score value, lifespan, and spawn weight.

## Background
Orb types are currently defined in separate scripts (blue_orb.gd, red_orb.gd, half_solid_orb.gd) with hardcoded values. A unified definition resource enables data-driven orb configuration and easier addition of new orb types.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.6: OrbDefinition Resource)

**Additional References:**
- specs/ai-refactor-prep/context.md (Orb Score Values)
- specs/ai-refactor-prep/plan.md (Step 8)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/entities/orb/orb_definition.gd` with class_name OrbDefinition extends Resource
2. Properties with @export:
   - `type_name: StringName`
   - `display_name: String`
   - `score_value: int = 1`
   - `lifespan_seconds: float = 30.0`
   - `scene: PackedScene` (optional)
   - `sprite_texture: Texture2D` (optional)
   - `has_physics_body: bool = false`
   - `spawn_weight: float = 1.0`

## Dependencies
- None (foundation for orb system)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_orb_definition.gd` first
2. Create directory structure `scripts/entities/orb/`
3. Implement the resource class
4. Verify default values and custom values work

## Acceptance Criteria

1. **Default Values**
   - Given a new OrbDefinition
   - When accessing properties without setting them
   - Then `score_value` is 1, `lifespan_seconds` is 30.0, `spawn_weight` is 1.0

2. **Custom Values**
   - Given a new OrbDefinition
   - When setting `type_name = &"test"`, `score_value = 10`, `lifespan_seconds = 15.0`
   - Then those properties hold the custom values

3. **StringName Type**
   - Given an OrbDefinition
   - When setting `type_name = &"blue"`
   - Then `type_name` is a StringName with value "blue"

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all OrbDefinition tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb-system, resource, data-driven
- **Required Skills**: GDScript, Godot 4.x, Resource
