---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Combo Starter Orb

## Description
Create the Combo Starter orb resource that initiates a combo chain, incrementing score multiplier with each subsequent orb collected.

## Background
The Combo Starter orb is a RARE orb that starts a combo chain. When collected, it sets up a 10-second window where each orb collected increments the combo counter. The combo value is added to the base score of collected orbs.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/combo_starter_orb.tres`:
   - display_name = "Combo Starter"
   - base_score = 3
   - rarity = RARE
   - behaviors = [
       ScoreBehavior(score_value=3),
       TimedModifierBehavior(effect_id="combo_chain", effect_value=0, duration=10.0)
     ]
2. Note: ScoreBehavior needs to add combo_chain value to base score and increment combo_chain

## Dependencies
- Task 04: ScoreBehavior (must handle combo_chain)
- Task 10: TimedModifierBehavior
- Task 03: EffectManager (combo_chain increments)

## Implementation Approach
1. **Create resource file**
   - Create .tres with combo_chain effect starting at 0
2. **Update ScoreBehavior if needed**
   - Ensure combo_chain value is added to score
   - Ensure combo_chain is incremented after each orb
3. **Test**
   - Test combo increments
   - Test combo resets on expiration
4. **Manual demo**
   - Collect combo starter, then orbs, verify score increases

## Acceptance Criteria

1. **Resource Loads**
   - Given combo_starter_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Combo Increments**
   - Given combo_chain effect is active
   - When orb is collected
   - Then combo_chain value increments

3. **Combo Adds To Score**
   - Given combo_chain value is 3
   - When orb with base_score=2 is collected
   - Then score equals 2 + 3 = 5

4. **Combo Expires**
   - Given combo_chain effect with 10s duration
   - When 10 seconds pass
   - Then combo_chain effect is removed

5. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: orb, effect, combo
- **Required Skills**: GDScript, Godot Resources
