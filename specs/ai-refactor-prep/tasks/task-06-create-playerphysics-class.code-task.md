---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create PlayerPhysics Static Class

## Description
Create the `PlayerPhysics` static class with pure functions for player movement calculations: coyote time checks, jump buffering, gravity calculation, and horizontal velocity calculation.

## Background
Player physics logic is currently embedded in `physics_player.gd`. Extracting to static functions enables unit testing without scene instantiation and makes the complex movement calculations (coyote time, jump buffer) testable in isolation.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.4: PlayerPhysics Static Class)

**Additional References:**
- specs/ai-refactor-prep/context.md (Player Constants)
- specs/ai-refactor-prep/plan.md (Step 6)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/systems/physics/player_physics.gd` with class_name PlayerPhysics
2. Implement `static func can_coyote(time_left_ground: int, current_time: int, timeout_ms: float) -> bool`
3. Implement `static func has_buffered_jump(time_pressed: int, current_time: int, timeout_ms: float) -> bool`
4. Implement `static func calculate_gravity(current_velocity_y: float, is_grounded: bool, ended_jump_early: bool, config: PlayerPhysicsConfig, delta: float) -> float`
5. Implement `static func calculate_horizontal_velocity(current: float, direction: float, target_speed: float, config: PlayerPhysicsConfig, delta: float) -> float`
6. Handle null config gracefully

## Dependencies
- task-04-create-physics-config-resources (requires PlayerPhysicsConfig)

## Implementation Approach
1. TDD: Update existing `tests/unit/test_player_movement.gd` with static function tests
2. Implement static functions one at a time
3. Match behavior from existing `physics_player.gd` implementation
4. Verify tests pass

## Acceptance Criteria

1. **Coyote Time Within Window**
   - Given time_left_ground is 1000ms and current_time is 1100ms
   - When calling `PlayerPhysics.can_coyote(1000, 1100, 150.0)`
   - Then result is true (within 150ms window)

2. **Coyote Time Outside Window**
   - Given time_left_ground is 1000ms and current_time is 1200ms
   - When calling `PlayerPhysics.can_coyote(1000, 1200, 150.0)`
   - Then result is false (outside 150ms window)

3. **Buffered Jump Within Window**
   - Given time_pressed is 1000ms and current_time is 1100ms
   - When calling `PlayerPhysics.has_buffered_jump(1000, 1100, 150.0)`
   - Then result is true

4. **Gravity When Grounded**
   - Given velocity_y is 0, is_grounded is true, and a PlayerPhysicsConfig
   - When calling `calculate_gravity(0, true, false, config, 0.016)`
   - Then result equals `config.grounding_force`

5. **Gravity When Falling**
   - Given velocity_y is 100, is_grounded is false
   - When calling `calculate_gravity(100, false, false, config, 0.016)`
   - Then result is greater than 100 (gravity applied)

6. **Early Jump Gravity Modifier**
   - Given velocity_y is -100, ended_jump_early is true
   - When calling `calculate_gravity(-100, false, true, config, 0.016)`
   - Then gravity is multiplied by `early_jump_gravity_modifier`

7. **Horizontal Acceleration**
   - Given current velocity is 0, direction is 1.0, target_speed is 120
   - When calling `calculate_horizontal_velocity(0, 1.0, 120, config, 0.016)`
   - Then result moves toward target using initial_acceleration

8. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all PlayerPhysics tests pass

## Metadata
- **Complexity**: Medium-High
- **Labels**: physics, static-class, testability, player-movement
- **Required Skills**: GDScript, Godot 4.x, platformer physics
