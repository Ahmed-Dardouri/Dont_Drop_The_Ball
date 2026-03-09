---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create Physics Config Resources

## Description
Create `BallPhysicsConfig` and `PlayerPhysicsConfig` resource classes that encapsulate physics parameters with default values matching the existing `Constants.gd` values.

## Background
Physics parameters are currently hardcoded in `Constants.gd`. Moving them to Resource classes enables editor-editable configs, easier testing with custom values, and data-driven physics tuning without code changes.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 5: Data Models - Config Resources)

**Additional References:**
- specs/ai-refactor-prep/context.md (Current Physics Constants, Player Constants)
- specs/ai-refactor-prep/plan.md (Step 4)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/ball_physics_config.gd`:
   - `max_speed: float = 900.0`
   - `max_fall_speed: float = 500.0`
   - `air_friction: float = 9.0`
2. Create `scripts/data/player_physics_config.gd`:
   - `jump_power: int = -700`
   - `move_speed: int = 120`
   - `acceleration: float = 1500.0`
   - `initial_acceleration: float = 2000.0`
   - `deceleration: float = 10000.0`
   - `coyote_timeout: float = 150.0`
   - `jump_buffer_timeout: float = 150.0`
   - `fall_acceleration: float = 1800.0`
   - `max_fall_speed: float = 800.0`
   - `grounding_force: float = 1.5`
   - `early_jump_gravity_modifier: float = 3.0`
3. All fields must use `@export` for editor visibility

## Dependencies
- None (independent foundation task)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_physics_configs.gd` first
2. Create directory structure `scripts/data/`
3. Implement both resource classes
4. Verify default values match Constants.gd values
5. Run tests

## Acceptance Criteria

1. **BallPhysicsConfig Defaults**
   - Given a new `BallPhysicsConfig`
   - When accessing properties
   - Then `max_speed` is 900.0, `max_fall_speed` is 500.0, `air_friction` is 9.0

2. **BallPhysicsConfig Custom Values**
   - Given a new `BallPhysicsConfig`
   - When setting `max_speed = 1000.0`
   - Then the property holds the custom value

3. **PlayerPhysicsConfig Defaults**
   - Given a new `PlayerPhysicsConfig`
   - When accessing properties
   - Then `jump_power` is -700, `move_speed` is 120, `coyote_timeout` is 150.0

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all physics config tests pass

## Metadata
- **Complexity**: Low
- **Labels**: config, resources, physics, data-driven
- **Required Skills**: GDScript, Godot 4.x, Resource
