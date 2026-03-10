---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Score Multiplier Orb

## Description
Create the Score Multiplier orb resource that doubles score for 45 seconds when collected.

## Background
The Score Multiplier orb is an UNCOMMON orb that applies a 2x score multiplier effect. When collected, all subsequent score gains are doubled for 45 seconds. The effect stacks multiplicatively with a cap of 10x.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/score_multiplier_orb.tres`:
   - display_name = "Score Multiplier"
   - base_score = 3
   - rarity = UNCOMMON
   - texture = appropriate sprite
   - behaviors = [
       ScoreBehavior(score_value=3),
       TimedModifierBehavior(effect_id="score_multiplier", effect_value=2.0, duration=45.0)
     ]
2. Add test for orb resource loading and behavior execution
3. Verify stacking works with EffectManager

## Dependencies
- Task 04: ScoreBehavior
- Task 10: TimedModifierBehavior
- Task 07: Migrate Existing Orbs to Resources (pattern to follow)

## Implementation Approach
1. **Create resource file**
   - Create .tres with correct configuration
2. **Test**
   - Verify resource loads
   - Test behavior execution
3. **Manual demo**
   - Spawn in game, collect, verify score doubles

## Acceptance Criteria

1. **Resource Loads**
   - Given score_multiplier_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Behavior Executes**
   - Given Score Multiplier orb is collected
   - When score is added afterward
   - Then score is doubled

3. **Duration Correct**
   - Given Score Multiplier orb is collected
   - When 45 seconds pass
   - Then effect expires

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb, effect, multiplier
- **Required Skills**: GDScript, Godot Resources
