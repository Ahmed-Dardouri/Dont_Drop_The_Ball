---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Implement MovementBehavior

## Description
Implement the MovementBehavior class that applies movement patterns to orbs (for Drifter orb type). Supports horizontal oscillation, vertical oscillation, and circular movement.

## Background
Drifter orbs move in a readable pattern while remaining collectible. MovementBehavior provides the per-frame position updates via the `process()` method called from GenericOrb._process().

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.4 - MovementBehavior)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 6)
- scripts/data/behaviors/orb_behavior.gd (base class)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/movement_behavior.gd`
2. Extend OrbBehavior class
3. Properties:
   - `enum MovementType { OSCILLATE_HORIZONTAL, OSCILLATE_VERTICAL, CIRCULAR }`
   - `@export var movement_type: MovementType = MovementType.OSCILLATE_HORIZONTAL`
   - `@export var amplitude: float = 50.0`
   - `@export var speed: float = 2.0`
4. Add `var _time: float = 0.0` for time tracking
5. Implement `process(orb: Node, delta: float) -> void`:
   - Accumulate time with delta * speed
   - Calculate offset based on movement_type
   - Apply offset to orb.position
6. Implement `_calculate_offset() -> Vector2` for each movement type

## Dependencies
- task-02-behavior-process-loop (requires process() to be called from GenericOrb)

## Implementation Approach
1. TDD: Write test_oscillate_horizontal_produces_x_offset
2. TDD: Write test_oscillate_vertical_produces_y_offset
3. TDD: Write test_time_accumulates_with_delta
4. Implement MovementBehavior to pass all tests

## Acceptance Criteria

1. **Horizontal Oscillation**
   - Given movement_type = OSCILLATE_HORIZONTAL, amplitude = 50
   - When process() is called multiple times with delta
   - Then orb.position.x oscillates using cos(time * speed) * amplitude
   - And orb.position.y remains unchanged

2. **Vertical Oscillation**
   - Given movement_type = OSCILLATE_VERTICAL, amplitude = 50
   - When process() is called multiple times with delta
   - Then orb.position.y oscillates using cos(time * speed) * amplitude
   - And orb.position.x remains unchanged

3. **Circular Movement**
   - Given movement_type = CIRCULAR, amplitude = 50
   - When process() is called multiple times with delta
   - Then orb.position moves in a circle using (cos, sin) * amplitude

4. **Time Accumulates**
   - Given speed = 2.0
   - When process(orb, 0.5) is called
   - Then _time increases by 1.0 (0.5 * 2.0)

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests in test_movement_behavior.gd pass

## Metadata
- **Complexity**: Low
- **Labels**: behavior, movement, drifter
- **Required Skills**: GDScript, trigonometry, time-based animation
