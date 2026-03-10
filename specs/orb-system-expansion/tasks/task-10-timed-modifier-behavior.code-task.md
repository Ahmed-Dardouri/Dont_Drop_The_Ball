---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create TimedModifierBehavior

## Description
Create the `TimedModifierBehavior` that applies timed effects to the EffectManager when an orb is collected.

## Background
TimedModifierBehavior is used by orbs that apply temporary effects like score multipliers, slow fall, time slow, etc. When executed, it calls EffectManager.apply_effect() with the configured effect_id, value, and duration.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/timed_modifier_behavior.gd` extending OrbBehavior
2. Add `@export` properties:
   - `var effect_id: String = ""`
   - `var effect_value: Variant = 1.0`
   - `var duration: float = 10.0`
3. Implement `execute(context: Dictionary) -> void`:
   - Call `EffectManager.apply_effect(effect_id, effect_value, duration)`

## Dependencies
- Task 02: OrbBehavior Abstract Base Class
- Task 03: EffectManager Singleton

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_timed_modifier_behavior.gd`
   - Test that effect is applied to EffectManager
   - Test that correct value is used
   - Test that correct duration is used
2. **Implement minimal code to pass**
   - Create TimedModifierBehavior class
   - Implement execute method
3. **Refactor while keeping tests green**
   - Ensure clean code structure

## Acceptance Criteria

1. **Effect Applied**
   - Given TimedModifierBehavior with effect_id="test_effect", effect_value=2.0, duration=10.0
   - When execute() is called
   - Then EffectManager.has_effect("test_effect") is true

2. **Correct Value**
   - Given TimedModifierBehavior with effect_value=3.0
   - When execute() is called
   - Then EffectManager.get_effect_value("test_effect") equals 3.0

3. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_timed_modifier_behavior.gd pass

## Metadata
- **Complexity**: Low
- **Labels**: behavior, effects
- **Required Skills**: GDScript
