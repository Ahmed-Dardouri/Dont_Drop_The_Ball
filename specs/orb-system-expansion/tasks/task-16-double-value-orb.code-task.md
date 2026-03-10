---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Double Value Orb

## Description
Create the Double Value orb resource that doubles the score of the NEXT orb collected.

## Background
The Double Value orb is an UNCOMMON orb that applies a one-time double score effect. Unlike other effects, this one lasts until used (duration=-1) and is consumed when the next orb is collected.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (see DURATION_PERMANENT constant)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/double_value_orb.tres`:
   - display_name = "Double Value"
   - base_score = 1
   - rarity = UNCOMMON
   - behaviors = [
       ScoreBehavior(score_value=1),
       TimedModifierBehavior(effect_id="double_value", effect_value=true, duration=-1.0)
     ]
2. Note: ScoreBehavior already handles consuming double_value effect

## Dependencies
- Task 04: ScoreBehavior (must consume double_value)
- Task 10: TimedModifierBehavior
- Task 03: EffectManager (DURATION_PERMANENT = -1.0)

## Implementation Approach
1. **Create resource file**
   - Create .tres with duration=-1.0 for permanent until used
2. **Verify ScoreBehavior**
   - Ensure double_value is consumed after use
3. **Test**
   - Test one-time effect consumption
4. **Manual demo**
   - Collect double value, then another orb, verify score doubled once

## Acceptance Criteria

1. **Resource Loads**
   - Given double_value_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Effect Applied Until Used**
   - Given double_value effect is applied
   - When first orb is collected
   - Then that orb's score is doubled
   - And double_value effect is removed

3. **No Double Application**
   - Given double_value effect is applied
   - When two orbs are collected
   - Then only first orb's score is doubled

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb, effect, one-time
- **Required Skills**: GDScript, Godot Resources
