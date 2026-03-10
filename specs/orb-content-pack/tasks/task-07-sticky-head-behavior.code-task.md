---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: StickyHeadBehavior + Ball Integration

## Description
Implement the StickyHeadBehavior class and integrate it with the ball's collision handling. When the sticky_head effect is active, the ball's vertical velocity is dampened on player collisions, giving the player more control.

## Background
The Sticky Head Orb provides a temporary effect that makes the ball "stickier" when bouncing off the player. This is achieved by reducing the ball's vertical velocity on player collision. The effect must ONLY apply on player collision, not every frame, to preserve the core bounce mechanic.

**CRITICAL:** This task requires Task 1 (Player Group Fix) to be completed first, as it depends on `body.is_in_group("player")`.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.6)
- Plan: specs/orb-content-pack/plan.md (Step 7)

**Additional References:**
- scripts/ball.gd (existing _on_body_entered handler)
- scripts/effect_manager.gd (effect system)
- Task 1: Player Group Fix

## Technical Requirements

### Behavior Class:
1. Create `scripts/data/behaviors/sticky_head_behavior.gd` extending OrbBehavior
2. Export `damping_factor: float` with default 0.5 (50% velocity)
3. Export `duration: float` with default 15.0 seconds
4. In `execute()`: apply "sticky_head" effect via EffectManager

### Ball Integration:
5. Modify `scripts/ball.gd` in `_on_body_entered(body)`:
   - Add check: `if body.is_in_group("player") and EffectManager.has_effect("sticky_head")`
   - Apply: `linear_velocity.y *= damping_factor`
6. This must NOT affect ground collision (game over) or half_solid collision

## Dependencies
- Task 1: Player Group Fix (MUST be completed first)
- scripts/data/behaviors/orb_behavior.gd (base class)
- scripts/effect_manager.gd (for effect application)
- scripts/ball.gd (for collision integration)

## Implementation Approach
1. **TDD: Write failing tests first**
   - Create `tests/unit/test_sticky_head_behavior.gd` (behavior tests)
   - Create `tests/unit/test_ball_sticky_head_integration.gd` (integration tests)
   - Test effect_applied
   - Test damping_value_correct
   - Test velocity_dampened_on_player_collision
   - Test no_dampen_without_effect
   - Test no_dampen_on_non_player
2. **Implement minimal code to pass**
   - Create StickyHeadBehavior class
   - Modify ball.gd collision handler
3. **Refactor while keeping tests green**
   - Ensure collision order doesn't break existing logic

## Acceptance Criteria

1. **Effect Applied**
   - Given StickyHeadBehavior with damping=0.5, duration=15.0
   - When execute() is called
   - Then EffectManager.has_effect("sticky_head") returns true

2. **Damping Value Correct**
   - Given StickyHeadBehavior with damping=0.5
   - When execute() is called
   - Then EffectManager.get_effect_value("sticky_head") == 0.5

3. **Velocity Dampened On Player Collision**
   - Given sticky_head effect is active and ball collides with player
   - When _on_body_entered(player) is called
   - Then ball.linear_velocity.y *= 0.5

4. **No Dampen Without Effect**
   - Given no sticky_head effect and ball collides with player
   - When _on_body_entered(player) is called
   - Then ball velocity is unchanged

5. **No Dampen On Non-Player**
   - Given sticky_head effect is active and ball hits ground
   - When _on_body_entered(ground) is called
   - Then only game_over logic runs, no velocity dampening

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 6 tests pass (3 behavior + 3 integration)

## Metadata
- **Complexity**: Medium-High
- **Labels**: behavior, sticky-head, collision, ball, physics, integration
- **Required Skills**: GDScript, Godot physics, signal handling
