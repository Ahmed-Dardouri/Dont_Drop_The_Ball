---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: TimedModifierBehavior Implementation

## Description
Implement the TimedModifierBehavior class that applies timed effects through the EffectManager. This is a generic behavior used by orbs that apply temporary modifiers (slow_fall, double_value, combo_chain, score_multiplier).

## Background
Several orb types need to apply effects with a duration. Rather than duplicating code, TimedModifierBehavior provides a reusable way to apply any effect. It integrates with the existing EffectManager singleton which handles stacking, expiration, and value management.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.3)
- Plan: specs/orb-content-pack/plan.md (Step 3)

**Additional References:**
- scripts/data/behaviors/orb_behavior.gd (base class)
- scripts/effect_manager.gd (effect system)

## Technical Requirements
1. Create `scripts/data/behaviors/timed_modifier_behavior.gd` extending OrbBehavior
2. Export `effect_id: String` (default empty)
3. Export `value: float` (default 1.0)
4. Export `duration: float` (default 10.0, -1 for permanent until used)
5. In `execute()`: call `EffectManager.apply_effect()` with parameters
6. Skip application if effect_id is empty

## Dependencies
- scripts/data/behaviors/orb_behavior.gd (base class)
- scripts/effect_manager.gd (for effect application)

## Implementation Approach
1. **TDD: Write failing tests first**
   - Create `tests/unit/test_timed_modifier_behavior.gd`
   - Test effect_applied
   - Test empty_effect_id_skipped
   - Test value_passed_correctly
2. **Implement minimal code to pass**
   - Create TimedModifierBehavior class
3. **Refactor while keeping tests green**
   - Ensure proper integration with EffectManager

## Acceptance Criteria

1. **Effect Applied**
   - Given TimedModifierBehavior with effect_id="slow_fall", value=0.5, duration=45
   - When execute() is called
   - Then EffectManager.has_effect("slow_fall") returns true

2. **Empty Effect ID Skipped**
   - Given TimedModifierBehavior with effect_id=""
   - When execute() is called
   - Then no effect is applied (no crash, no-op)

3. **Value Passed Correctly**
   - Given TimedModifierBehavior with value=0.3
   - When execute() is called
   - Then EffectManager.get_effect_value() returns 0.3

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 3 tests pass

## Metadata
- **Complexity**: Low
- **Labels**: behavior, effects, timed, modifier
- **Required Skills**: GDScript, Godot resources, effect systems
