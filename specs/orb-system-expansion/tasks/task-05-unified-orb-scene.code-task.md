---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Unified Orb Scene and Script

## Description
Create the unified `Orb` scene and script that replaces all existing orb types. This scene reads OrbData at spawn, executes behaviors on collection, handles spawn animation, and manages lifespan timer.

## Background
Currently there are separate scenes for blue_orb, red_orb, half_solid_orb, and generic_orb. The unified Orb scene replaces all of these by being data-driven - the same scene can represent any orb type based on its OrbData resource.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns - see existing generic_orb pattern)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/orb.gd` extending Node2D (or Area2D based on existing pattern)
2. Create `scenes/orb.tscn` with node structure:
   - Node2D (root) > Sprite2D, Area2D > CollisionShape2D, StaticBody2D (for half-solid), Timer
3. Implement properties:
   - `var orb_data: OrbData`
   - `var _is_spawning: bool = true`
   - `var _spawn_progress: float = 0.0`
4. Implement methods:
   - `setup(data: OrbData) -> void` - apply data to scene
   - `collect() -> void` - fire events, execute behaviors, queue_free
   - `_apply_data() -> void` - set sprite, scale, collision from data
   - `_process(delta: float) -> void` - handle spawn animation, lifespan
5. Handle half-solid collision: `linear_velocity = linear_velocity/3`
6. Spawn animation: fade in over 0.3 seconds
7. Lifespan: use Timer, queue_free on timeout

## Dependencies
- Task 01: OrbData Resource Class
- Task 02: OrbBehavior Abstract Base Class
- Task 04: ScoreBehavior

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_orb.gd`
   - Test setup applies data correctly
   - Test collect fires OrbCollectedEvent
   - Test spawn animation starts at alpha 0
2. **Implement minimal code to pass**
   - Create orb.gd with all methods
   - Create orb.tscn scene file
3. **Refactor while keeping tests green**
   - Ensure proper signal connections
   - Handle edge cases

## Acceptance Criteria

1. **Setup Applies Data**
   - Given a new Orb instance
   - When setup(data) is called with OrbData
   - Then orb_data equals the passed data

2. **Collect Fires Event**
   - Given an Orb with OrbData
   - When collect() is called
   - Then OrbCollectedEvent is fired

3. **Spawn Animation**
   - Given a newly spawned Orb
   - When _is_spawning is true
   - Then sprite.modulate.a equals 0.0 initially

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_orb.gd pass

## Metadata
- **Complexity**: High
- **Labels**: core, scene, orb
- **Required Skills**: GDScript, Godot Scenes
