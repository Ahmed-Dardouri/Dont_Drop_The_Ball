---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create BallPhysics Static Class

## Description
Create the `BallPhysics` static class with pure functions for ball velocity calculations: clamping max speed, clamping fall speed, applying air friction, and a combined `process_velocity` function.

## Background
Ball physics logic is currently embedded in `ball.gd`. Extracting to static functions enables unit testing without scene instantiation and makes the physics calculations reusable and testable in isolation.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.3: BallPhysics Static Class)

**Additional References:**
- specs/ai-refactor-prep/context.md (Current Physics Constants)
- specs/ai-refactor-prep/plan.md (Step 5)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/systems/physics/ball_physics.gd` with class_name BallPhysics
2. Implement `static func clamp_max_speed(velocity: Vector2, max_speed: float) -> Vector2`
3. Implement `static func clamp_fall_speed(velocity: Vector2, max_fall_speed: float) -> Vector2`
4. Implement `static func apply_air_friction(velocity: Vector2, friction: float) -> Vector2`
5. Implement `static func process_velocity(velocity: Vector2, config: BallPhysicsConfig) -> Vector2`
6. Handle edge cases (null config, zero/negative limits)

## Dependencies
- task-04-create-physics-config-resources (requires BallPhysicsConfig)

## Implementation Approach
1. TDD: Update existing or create new tests in `tests/unit/test_ball_physics.gd`
2. Create directory structure `scripts/systems/physics/`
3. Implement static functions one at a time, verifying tests pass after each
4. Verify `process_velocity` combines all effects correctly

## Acceptance Criteria

1. **Clamp Max Speed**
   - Given velocity is `Vector2(1000, 0)` and max_speed is 900.0
   - When calling `BallPhysics.clamp_max_speed(velocity, max_speed)`
   - Then result has length approximately 900.0

2. **Clamp Fall Speed**
   - Given velocity is `Vector2(100, 600)` and max_fall_speed is 500.0
   - When calling `BallPhysics.clamp_fall_speed(velocity, max_fall_speed)`
   - Then result.y is 500.0 and result.x is unchanged

3. **Apply Air Friction**
   - Given velocity is `Vector2(100, 50)` and friction is 9.0
   - When calling `BallPhysics.apply_air_friction(velocity, friction)`
   - Then result.x is reduced (multiplied by (1 - 9/1000))

4. **Process Velocity Combines All**
   - Given velocity is `Vector2(1000, 600)` and a default BallPhysicsConfig
   - When calling `BallPhysics.process_velocity(velocity, config)`
   - Then result is clamped to max_speed 900.0, fall_speed 500.0, and friction applied

5. **Null Config Handling**
   - Given velocity is `Vector2(100, 50)` and config is null
   - When calling `BallPhysics.process_velocity(velocity, null)`
   - Then original velocity is returned unchanged

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all BallPhysics tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: physics, static-class, testability
- **Required Skills**: GDScript, Godot 4.x, Vector math
