---
status: completed
created: 2026-03-08
started: 2026-03-09
completed: 2026-03-09
---
# Task: Create HalfSolidOrb Subclass

## Description
Create the `HalfSolidOrb` subclass that provides bounce-on-first-hit and collect-on-second-hit behavior for half-solid orbs.

## Background
Half-solid orbs have unique behavior: the ball bounces off on first collision, and the orb is only collected on the second collision. This requires tracking hit state and modifying collision response.

## Reference Documentation
**Required:**
- Design: specs/ai-refactor-prep/design.md (Section 4.9: HalfSolidOrb Subclass)

**Additional References:**
- specs/ai-refactor-prep/context.md (Half-Solid Orb Dual Behavior)
- specs/ai-refactor-prep/plan.md (Step 14)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/entities/orb/half_solid_orb.gd` with class_name HalfSolidOrb extends Orb
2. Property: `var _was_hit: bool = false`
3. Override `_ready()` to add to "half_solid" group
4. Override `_on_body_entered(body: Node2D)`:
   - First hit: set `_was_hit = true`, bounce ball (velocity /= 3)
   - Second hit: call `collect()`
5. Method: `_on_ball_collision(ball: Node2D)` - Apply bounce effect

## Dependencies
- task-13-create-unified-orb-class (requires Orb base class)

## Implementation Approach
1. TDD: Write test file `tests/unit/test_half_solid_orb.gd` first
2. Implement subclass extending Orb
3. Override collision handling for bounce-then-collect behavior
4. Verify ball velocity modification works correctly

## Acceptance Criteria

1. **First Hit Bounces Ball**
   - Given HalfSolidOrb with `_was_hit = false`
   - When ball collides with orb
   - Then `_was_hit` becomes true
   - And ball's linear_velocity is divided by 3

2. **Second Hit Collects**
   - Given HalfSolidOrb with `_was_hit = true`
   - When ball collides with orb
   - Then `collect()` is called and score is added

3. **Only Ball Triggers Behavior**
   - Given HalfSolidOrb
   - When non-ball body collides
   - Then no bounce or collection occurs

4. **In Half Solid Group**
   - Given HalfSolidOrb instance
   - When checking groups
   - Then `is_in_group("half_solid")` is true

5. **Inherits Orb Behavior**
   - Given HalfSolidOrb
   - When definition.score_value is 8
   - Then collecting adds 8 to score

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all HalfSolidOrb tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: orb-system, subclass, physics
- **Required Skills**: GDScript, Godot 4.x, inheritance
