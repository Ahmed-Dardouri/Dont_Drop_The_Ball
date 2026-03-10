---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create MovementBehavior

## Description
Create the `MovementBehavior` that handles orb movement patterns like directional drift and oscillation.

## Background
MovementBehavior is used by orbs like Drifter that move while on screen. It supports directional movement and oscillation patterns. Must include viewport bounds checking to prevent orbs from drifting off-screen.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (see Design Concerns - MovementBehavior bounds)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/movement_behavior.gd` extending OrbBehavior
2. Add `@export` properties:
   - `var speed: float = 50.0`
   - `var direction: Vector2 = Vector2.RIGHT`
   - `var oscillate: bool = false`
   - `var oscillate_distance: float = 100.0`
   - `var spawn_delay: float = 0.3` (wait for spawn animation)
3. Implement `process(orb: Node, delta: float) -> void`:
   - Skip if during spawn_delay
   - Move orb in direction at speed
   - If oscillate, reverse direction at boundaries
   - Clamp position to viewport bounds with margin

## Dependencies
- Task 02: OrbBehavior Abstract Base Class

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_movement_behavior.gd`
   - Test that orb moves when process is called
   - Test oscillation reverses direction
   - Test viewport bounds clamping
2. **Implement minimal code to pass**
   - Create MovementBehavior class
   - Implement process method with movement logic
3. **Refactor while keeping tests green**
   - Ensure smooth movement

## Acceptance Criteria

1. **Orb Moves**
   - Given MovementBehavior with speed=50.0
   - When process(orb, 1.0) is called
   - Then orb.global_position has changed

2. **Oscillation Works**
   - Given MovementBehavior with oscillate=true, oscillate_distance=100.0
   - When process is called multiple times
   - Then direction reverses at boundary

3. **Viewport Bounds**
   - Given an orb near screen edge
   - When process is called
   - Then orb position is clamped within viewport

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_movement_behavior.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, movement
- **Required Skills**: GDScript, Godot Physics
