---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Implement ComboStarterBehavior

## Description
Implement the ComboStarterBehavior class that starts or extends a combo window using EffectManager.

## Background
Combo starter orbs begin or boost a combo/multiplier window. When collected, they check if a combo_chain effect already exists and increment it, or start a new combo at the base value.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.4 - ComboStarterBehavior)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 7)
- scripts/data/behaviors/orb_behavior.gd (base class)
- scripts/effect_manager.gd (EffectManager API)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/combo_starter_behavior.gd`
2. Extend OrbBehavior class
3. Properties:
   - `@export var base_duration: float = 10.0`
   - `@export var combo_increment: int = 1`
4. Implement `execute(context: Dictionary) -> void`:
   - Check if "combo_chain" effect exists via EffectManager.has_effect()
   - If exists, get current value and increment by combo_increment
   - If not exists, start at 1 (or base value)
   - Apply/refresh effect via EffectManager.apply_effect()

## Dependencies
- None (uses existing EffectManager)

## Implementation Approach
1. TDD: Write test_first_combo_starts_at_base_value
2. TDD: Write test_existing_combo_increments
3. TDD: Write test_duration_refreshed_on_stack
4. Implement ComboStarterBehavior to pass all tests

## Acceptance Criteria

1. **First Combo Starts at Base**
   - Given no combo_chain effect exists
   - When execute() is called
   - Then EffectManager.apply_effect("combo_chain", 1, base_duration, ...) is called

2. **Existing Combo Increments**
   - Given combo_chain effect exists with value 3
   - And combo_increment = 1
   - When execute() is called
   - Then EffectManager.apply_effect("combo_chain", 4, base_duration, ...) is called

3. **Duration Refreshed on Stack**
   - Given combo_chain effect exists with 5 seconds remaining
   - And base_duration = 10.0
   - When execute() is called
   - Then effect duration is refreshed to 10.0 seconds

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests in test_combo_starter_behavior.gd pass

## Metadata
- **Complexity**: Low
- **Labels**: behavior, combo, effect-manager
- **Required Skills**: GDScript, EffectManager API
