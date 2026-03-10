---
status: completed
created: 2026-03-10
started: 2026-03-10
completed: 2026-03-10
---
# Task: Create EffectManager Singleton

## Description
Create the `EffectManager` autoload singleton that tracks active effects with duration, handles stacking rules, applies global effects like time_scale, and clears on game over.

## Background
The EffectManager is the central system for managing timed effects in the game. It handles effect application, stacking (multiplicative for most effects), expiration, and global state changes like Engine.time_scale for time_slow effects.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/effect_manager.gd` extending Node
2. Implement `ActiveEffect` inner class with: `effect_id`, `value`, `remaining_duration`, `source`
3. Implement public methods:
   - `apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null) -> void`
   - `remove_effect(effect_id: String) -> void`
   - `has_effect(effect_id: String) -> bool`
   - `get_effect_value(effect_id: String) -> Variant`
   - `clear_all_effects() -> void`
4. Implement stacking rules:
   - `score_multiplier`: multiply values, cap at 10x
   - `slow_fall`: multiply values, cap at 0.9 (90% reduction)
   - `time_slow`: multiply values, cap at 0.25x, sets Engine.time_scale
   - `combo_chain`: increment value, no cap
   - `double_value`: single instance, no stacking
5. Add `DURATION_PERMANENT: float = -1.0` constant
6. Register as autoload in `project.godot`
7. Listen for `GameOverEvent` to clear effects

## Dependencies
- None (this is Step 3, independent)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_effect_manager.gd`
   - Test apply_effect and has_effect
   - Test get_effect_value
   - Test effect expiration
   - Test stacking for score_multiplier
   - Test time_slow sets Engine.time_scale
2. **Implement minimal code to pass**
   - Create EffectManager with all methods
   - Implement _process for expiration checking
3. **Refactor while keeping tests green**
   - Clean up code structure
   - Add proper type hints

## Acceptance Criteria

1. **Effect Applied**
   - Given EffectManager.apply_effect("test", 2.0, 10.0) is called
   - When has_effect("test") is checked
   - Then result is true

2. **Effect Value Retrieved**
   - Given EffectManager.apply_effect("test", 2.0, 10.0) is called
   - When get_effect_value("test") is called
   - Then result equals 2.0

3. **Effect Expiration**
   - Given EffectManager.apply_effect("test", 1.0, 0.1) is called
   - When 0.2 seconds pass
   - Then has_effect("test") is false

4. **Score Multiplier Stacking**
   - Given apply_effect("score_multiplier", 2.0, 10.0) is called twice
   - When get_effect_value("score_multiplier") is called
   - Then result equals 4.0

5. **Time Slow Sets Engine Time Scale**
   - Given apply_effect("time_slow", 0.5, 10.0) is called
   - When checked immediately
   - Then Engine.time_scale equals 0.5

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_effect_manager.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: core, singleton, effects
- **Required Skills**: GDScript, Godot Autoloads
