---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create ScoreBehavior

## Description
Create the `ScoreBehavior` concrete behavior that handles score addition, applies multipliers from EffectManager, and consumes double_value effect when present.

## Background
ScoreBehavior is the most common behavior - every orb has it. It fires AddScoreEvent with the calculated score, applying any active score_multiplier or double_value effects from EffectManager.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/score_behavior.gd` extending OrbBehavior
2. Add `@export var score_value: int = 1`
3. Implement `execute(context: Dictionary) -> void`:
   - Calculate final score: base * multiplier * double_value
   - Fire `AddScoreEvent.invoke(final_score)`
   - If double_value active, call `EffectManager.remove_effect("double_value")`
4. Handle combo_chain: increment base score by combo_chain value

## Dependencies
- Task 02: OrbBehavior Abstract Base Class
- Task 03: EffectManager Singleton

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_score_behavior.gd`
   - Test base score without effects
   - Test with score_multiplier effect
   - Test with double_value effect (consumed after use)
   - Test with combo_chain effect
2. **Implement minimal code to pass**
   - Create ScoreBehavior extending OrbBehavior
   - Implement execute with multiplier logic
3. **Refactor while keeping tests green**
   - Clean calculation logic

## Acceptance Criteria

1. **Base Score**
   - Given ScoreBehavior with score_value=5
   - When execute() is called with no active effects
   - Then AddScoreEvent is fired with value 5

2. **Score With Multiplier**
   - Given ScoreBehavior with score_value=5 and EffectManager has score_multiplier=2.0
   - When execute() is called
   - Then AddScoreEvent is fired with value 10

3. **Score With Double Value**
   - Given ScoreBehavior with score_value=5 and EffectManager has double_value=true
   - When execute() is called
   - Then AddScoreEvent is fired with value 10
   - And double_value effect is removed

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_score_behavior.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, scoring
- **Required Skills**: GDScript, Event System
