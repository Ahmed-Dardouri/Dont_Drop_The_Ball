---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Time Slow Orb

## Description
Create the Time Slow orb resource that slows game time to 50% for 10 seconds.

## Background
The Time Slow orb is a RARE orb that slows the entire game by setting Engine.time_scale to 0.5. This gives players more reaction time. The effect has a shorter duration (10s) because it affects the whole game.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/time_slow_orb.tres`:
   - display_name = "Time Slow"
   - base_score = 5
   - rarity = RARE
   - behaviors = [
       ScoreBehavior(score_value=5),
       TimedModifierBehavior(effect_id="time_slow", effect_value=0.5, duration=10.0)
     ]
2. Note: EffectManager already handles setting Engine.time_scale when time_slow effect is applied/expired

## Dependencies
- Task 04: ScoreBehavior
- Task 10: TimedModifierBehavior
- Task 03: EffectManager (must handle time_slow → Engine.time_scale)

## Implementation Approach
1. **Create resource file**
   - Create .tres with correct configuration
2. **Verify EffectManager**
   - Ensure time_slow sets Engine.time_scale
   - Ensure time_scale resets to 1.0 when effect expires
3. **Test**
   - Test Engine.time_scale changes
4. **Manual demo**
   - Collect orb, verify game slows, verify returns to normal

## Acceptance Criteria

1. **Resource Loads**
   - Given time_slow_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Time Scale Modified**
   - Given time_slow effect is applied with value=0.5
   - When checked immediately
   - Then Engine.time_scale equals 0.5

3. **Time Scale Resets**
   - Given time_slow effect with 10s duration
   - When 10 seconds pass
   - Then Engine.time_scale equals 1.0

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb, effect, time
- **Required Skills**: GDScript, Godot Resources
