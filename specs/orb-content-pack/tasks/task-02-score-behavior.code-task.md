---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: ScoreBehavior Implementation

## Description
Implement the ScoreBehavior class that handles scoring when an orb is collected. This behavior applies base score and respects active score modifiers (double_value, score_multiplier).

## Background
The orb system uses OrbBehavior classes to define what happens when an orb is collected. ScoreBehavior is a fundamental behavior used by all orbs to award points. It must integrate with the existing ScoreManager singleton and EffectManager for multipliers.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.5)
- Plan: specs/orb-content-pack/plan.md (Step 2)

**Additional References:**
- scripts/data/behaviors/orb_behavior.gd (base class)
- scripts/effect_manager.gd (effect system)
- scripts/score_manager.gd (score handling)

## Technical Requirements
1. Create `scripts/data/behaviors/score_behavior.gd` extending OrbBehavior
2. Export `base_score: int` with default value of 1
3. In `execute()`: calculate final score applying double_value and score_multiplier effects
4. Call `ScoreManager.add_score()` with the calculated score
5. Handle cases where effects are not active

## Dependencies
- scripts/data/behaviors/orb_behavior.gd (base class)
- scripts/effect_manager.gd (for effect checking)
- scripts/score_manager.gd (for score application)

## Implementation Approach
1. **TDD: Write failing tests first**
   - Create `tests/unit/test_score_behavior.gd`
   - Test base_score_awarded
   - Test double_value_applied
   - Test score_multiplier_applied
   - Test combined_multipliers
2. **Implement minimal code to pass**
   - Create ScoreBehavior class with execute() method
3. **Refactor while keeping tests green**
   - Ensure clean integration with EffectManager

## Acceptance Criteria

1. **Base Score Awarded**
   - Given ScoreBehavior with base_score=5
   - When execute() is called with valid context
   - Then ScoreManager.add_score(5) is called

2. **Double Value Applied**
   - Given double_value effect is active and base_score=3
   - When execute() is called
   - Then score is doubled to 6

3. **Score Multiplier Applied**
   - Given score_multiplier=2x effect is active and base_score=5
   - When execute() is called
   - Then score is 10

4. **Combined Multipliers**
   - Given both double_value and score_multiplier=2x are active
   - When execute() is called
   - Then score is base * 2 * 2

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, scoring, effects, multipliers
- **Required Skills**: GDScript, Godot resources, effect systems
