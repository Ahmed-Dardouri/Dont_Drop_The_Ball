---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create OrbRegistry

## Description
Create the `OrbRegistry` static class that provides centralized orb type registration, lookup, and weighted random selection for spawning.

## Background
Orb types are currently scattered across multiple files. The registry pattern provides a single source of truth for orb definitions and enables weighted random selection based on spawn weights.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.7: OrbRegistry Static Class)

**Additional References:**
- specs/ai-refactor-prep/context.md (Orb Score Values)
- specs/ai-refactor-prep/plan.md (Step 9)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/entities/orb/orb_registry.gd` with class_name OrbRegistry
2. Static methods:
   - `reset() -> void` - Clear all definitions
   - `initialize() -> void` - Register default orb types
   - `register(def: OrbDefinition) -> void` - Add definition to registry
   - `get_definition(type_name: StringName) -> OrbDefinition` - Lookup by type
   - `get_all_definitions() -> Array` - Get all definitions
   - `get_weighted_random() -> OrbDefinition` - Weighted random selection
3. Default registrations on initialize:
   - Blue: score=2, lifespan=30s, weight=1.0, has_physics_body=false
   - Red: score=3, lifespan=30s, weight=1.0, has_physics_body=false
   - Half Solid: score=8, lifespan=18s, weight=0.5, has_physics_body=true
4. Handle unknown type lookups with `push_warning` and return null

## Dependencies
- task-08-create-orbdefinition-resource (requires OrbDefinition)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_orb_registry.gd` first
2. Implement static class with internal Dictionary storage
3. Implement weighted random using accumulated weights
4. Test default registration and custom registration

## Acceptance Criteria

1. **Initialize Registers Defaults**
   - Given OrbRegistry is reset
   - When calling `OrbRegistry.initialize()`
   - Then `get_definition(&"blue")`, `get_definition(&"red")`, `get_definition(&"half_solid")` all return valid definitions

2. **Unknown Type Returns Null**
   - Given initialized registry
   - When calling `get_definition(&"unknown")`
   - Then result is null and warning is logged

3. **Custom Registration Works**
   - Given reset registry
   - When calling `register(custom_def)` with `type_name = &"custom"`
   - Then `get_definition(&"custom")` returns the same definition

4. **Weighted Random Returns Valid**
   - Given initialized registry
   - When calling `get_weighted_random()` multiple times
   - Then all returned definitions are from the registry

5. **Weighted Random Respects Weights**
   - Given registry with blue(weight=1), red(weight=1), half_solid(weight=0.5)
   - When calling `get_weighted_random()` many times
   - Then distribution approximately matches weights (half_solid ~20% of time)

6. **Get All Definitions**
   - Given initialized registry
   - When calling `get_all_definitions()`
   - Then result contains all registered definitions

7. **Null/Invalid Registration Handled**
   - Given registry
   - When calling `register(null)` or register with null type_name
   - Then error is logged and registry unchanged

8. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all OrbRegistry tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: orb-system, registry-pattern, weighted-random
- **Required Skills**: GDScript, Godot 4.x
