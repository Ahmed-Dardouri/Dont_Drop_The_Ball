---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Slow Fall Orb

## Description
Create the Slow Fall orb resource that reduces ball fall speed by 50% for 45 seconds, and update ball.gd to poll EffectManager for this effect.

## Background
The Slow Fall orb is an UNCOMMON orb that makes the ball fall slower, giving players more time to react. This requires integration with the ball physics system to apply the effect modifier.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (see Ball Physics Integration)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/slow_fall_orb.tres`:
   - display_name = "Slow Fall"
   - base_score = 2
   - rarity = UNCOMMON
   - behaviors = [
       ScoreBehavior(score_value=2),
       TimedModifierBehavior(effect_id="slow_fall", effect_value=0.5, duration=45.0)
     ]
2. Update `scripts/ball.gd`:
   - Add `var base_fall_speed: float` to store original speed
   - Add `_apply_effect_modifiers()` method
   - Call in `_physics_process()`:
   ```gdscript
   func _apply_effect_modifiers():
       if EffectManager.has_effect("slow_fall"):
           fall_speed = base_fall_speed * EffectManager.get_effect_value("slow_fall")
       else:
           fall_speed = base_fall_speed
   ```

## Dependencies
- Task 04: ScoreBehavior
- Task 10: TimedModifierBehavior
- Task 03: EffectManager Singleton

## Implementation Approach
1. **Create resource file**
   - Create .tres with correct configuration
2. **Update ball.gd**
   - Add effect polling in physics process
3. **Test**
   - Test ball fall speed changes when effect active
4. **Manual demo**
   - Collect orb, verify ball falls slower

## Acceptance Criteria

1. **Resource Loads**
   - Given slow_fall_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Ball Fall Speed Modified**
   - Given EffectManager has slow_fall effect with value=0.5
   - When ball physics processes
   - Then fall_speed equals base_fall_speed * 0.5

3. **Effect Expires**
   - Given slow_fall effect with 45s duration
   - When 45 seconds pass
   - Then fall_speed returns to base_fall_speed

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: orb, effect, physics
- **Required Skills**: GDScript, Godot Physics
