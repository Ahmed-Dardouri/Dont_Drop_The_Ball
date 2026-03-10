---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: MovementBehavior Implementation

## Description
Implement the MovementBehavior class for the Drifter Orb. This behavior uses the `process()` method to move the orb in a sine wave oscillation pattern, making it a moving target for the player.

## Background
The Drifter Orb is an orb that moves in a predictable pattern, making it more challenging to collect. Unlike other behaviors that use `execute()`, this uses `process()` which is called every frame. The movement should be smooth and use `global_position` to avoid issues with parent node transforms.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.4)
- Plan: specs/orb-content-pack/plan.md (Step 6)

**Additional References:**
- scripts/data/behaviors/orb_behavior.gd (base class, process() method)

## Technical Requirements
1. Create `scripts/data/behaviors/movement_behavior.gd` extending OrbBehavior
2. Define enum `MovementPattern` with HORIZONTAL_OSCILLATE and VERTICAL_OSCILLATE
3. Export `pattern: MovementPattern` with default HORIZONTAL_OSCILLATE
4. Export `amplitude: float` with default 75.0
5. Export `speed: float` with default 2.0 (cycles per second)
6. Track `_initial_position`, `_time_elapsed`, `_initialized` internally
7. In `process()`: apply sine wave movement based on pattern
   - Formula: `offset = sin(time * speed * TAU) * amplitude`
8. Use `global_position` not `position`

## Dependencies
- scripts/data/behaviors/orb_behavior.gd (base class with process() method)

## Implementation Approach
1. **TDD: Write failing tests first**
   - Create `tests/unit/test_movement_behavior.gd`
   - Test horizontal_oscillation
   - Test vertical_oscillation
   - Test speed_affects_cycle
   - Test initial_position_captured
2. **Implement minimal code to pass**
   - Create MovementBehavior with oscillation logic
3. **Refactor while keeping tests green**
   - Ensure smooth movement using delta time

## Acceptance Criteria

1. **Horizontal Oscillation**
   - Given pattern=HORIZONTAL_OSCILLATE and amplitude=75
   - When process(1.0 seconds) is called
   - Then orb.global_position.x = initial_x + sin(TAU) * 75

2. **Vertical Oscillation**
   - Given pattern=VERTICAL_OSCILLATE and amplitude=50
   - When process(1.0 seconds) is called
   - Then orb.global_position.y = initial_y + sin(TAU) * 50

3. **Speed Affects Cycle**
   - Given speed=2 and process(0.5 seconds)
   - When comparing to speed=1 and process(1.0 seconds)
   - Then positions are the same (double speed = half time for same position)

4. **Initial Position Captured**
   - Given first process() call
   - When the orb has an initial global_position
   - Then _initial_position is set and _initialized is true

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, movement, oscillation, sine-wave, drifter
- **Required Skills**: GDScript, trigonometry, frame-based updates
