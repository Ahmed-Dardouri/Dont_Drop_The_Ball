---
status: completed
created: 2026-03-11
started: 2026-03-11
completed: 2026-03-11
---
# Task: ModeBase and EndlessMode

## Description
Create the abstract `ModeBase` class and the first concrete implementation `EndlessMode`. ModeBase defines lifecycle hooks that all modes implement, while EndlessMode provides the default endless gameplay behavior.

## Background
ModeBase follows the template method pattern - it defines the interface that ModeManager calls, and concrete modes override specific hooks. EndlessMode is the simplest mode: no win condition, score-based metric, and passthrough orb collection. This matches the existing default gameplay.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 3.3 ModeBase, Section 3.4 Concrete Modes)

**Additional References:**
- specs/game-mode-system/context.md (Mode Implementation Details)
- specs/game-mode-system/plan.md (Step 3 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/modes/` directory
2. Create `scripts/modes/mode_base.gd` with abstract lifecycle hooks:
   - `_on_start() -> void`
   - `_on_process(delta: float) -> void`
   - `_on_orb_collected(orb_data: OrbData, base_score: int) -> int`
   - `_check_win() -> bool`
   - `_check_lose() -> bool`
   - `_on_end() -> void`
   - `_get_metric() -> Dictionary`
   - `_get_final_score() -> int`
3. Create `scripts/modes/endless_mode.gd` extending ModeBase
4. EndlessMode behavior:
   - `_check_win()` always returns false
   - `_check_lose()` always returns false (handled by GameOverEvent)
   - `_on_orb_collected()` returns base_score unchanged
   - `_get_metric()` returns {"name": "score", "value": <current_score>}
5. Update endless_mode.tres to reference the implementation script

## Dependencies
- Task 01: Mode Data Foundation (requires ModeConfig)
- Task 02: ModeManager Singleton Core (ModeManager instantiates implementations)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_endless_mode.gd` with test cases:
     - test_check_win
     - test_check_lose
     - test_get_metric
     - test_on_orb_collected
2. **Implement minimal code to pass**
   - Create ModeBase with all hook methods
   - Create EndlessMode implementing hooks
   - Update endless_mode.tres with implementation reference
3. **Refactor while keeping tests green**
   - Ensure ModeManager can instantiate EndlessMode
   - Verify ModeBase is properly abstract (cannot be instantiated directly)

## Acceptance Criteria

1. **ModeBase Created**
   - Given the mode system needs a base class
   - When creating ModeBase
   - Then it has all required lifecycle hooks with correct signatures

2. **EndlessMode No Win**
   - Given an EndlessMode instance
   - When calling _check_win()
   - Then it returns false

3. **EndlessMode No Lose**
   - Given an EndlessMode instance
   - When calling _check_lose()
   - Then it returns false

4. **EndlessMode Metric**
   - Given an EndlessMode instance after start
   - When calling _get_metric()
   - Then it returns {"name": "score", "value": <current_score>}

5. **EndlessMode Orb Collection**
   - Given an EndlessMode instance
   - When calling _on_orb_collected(orb_data, 10)
   - Then it returns 10 (pass-through)

6. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests in test_endless_mode.gd pass

7. **Demo Works**
   - Given endless mode is started via ModeManager
   - When checking ModeManager._mode_impl
   - Then it is an instance of EndlessMode

## Metadata
- **Complexity**: Medium
- **Labels**: modes, abstract, endless
- **Required Skills**: GDScript, Inheritance Patterns
