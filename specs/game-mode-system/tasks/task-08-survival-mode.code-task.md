---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Survival Mode

## Description
Implement the Survival game mode with endless waves of increasing difficulty. Players advance through waves by collecting orbs, with each wave requiring more orbs and having faster spawn rates.

## Background
Survival mode introduces wave-based progression. Each wave requires more orbs to advance, and spawn intervals decrease (faster spawning) as waves progress. The final score is the wave number reached, not cumulative score. This creates a "how far can you get" challenge.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 3.4 Concrete Modes - SurvivalMode)

**Additional References:**
- specs/game-mode-system/context.md (Mode Implementation Details - SurvivalMode)
- specs/game-mode-system/plan.md (Step 8 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/modes/survival_mode.gd` extending ModeBase
2. Implement wave progression:
   - `_current_wave: int` starting at 1
   - `_orbs_collected_this_wave: int` tracking orbs in current wave
   - `_get_orbs_needed() -> int`: returns 3 + (wave * 2) (wave 1 = 5, wave 2 = 7, etc.)
   - `_get_spawn_interval() -> float`: returns max(0.5, 2.0 - (wave * 0.1))
3. Wave advancement:
   - When orbs_collected_this_wave >= orbs_needed: increment wave, reset counter
4. `_check_win()` always returns false (endless)
5. `_get_final_score()` returns `_current_wave`
6. Metric format: `{"name": "wave", "value": _current_wave, "max": 0}`
7. Create `resources/modes/survival_mode.tres` with:
   - mode_id: "survival"
   - display_name: "Survival"
   - description: "Survive as many waves as you can!"
   - has_win: false
   - hud_metric: "wave"
   - implementation: reference to survival_mode.gd

## Dependencies
- Task 03: ModeBase and EndlessMode (needs ModeBase)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_survival_mode.gd` with test cases:
     - test_initial_wave
     - test_orbs_needed_wave_1
     - test_orbs_needed_wave_3
     - test_spawn_interval_wave_1
     - test_spawn_interval_wave_5
     - test_advance_wave
     - test_final_score
     - test_metric
2. **Implement minimal code to pass**
   - Create SurvivalMode with wave logic
   - Create survival_mode.tres resource
3. **Refactor while keeping tests green**
   - Ensure wave math is correct
   - Handle edge cases (wave overflow protection)

## Acceptance Criteria

1. **Initial Wave**
   - Given a SurvivalMode instance
   - When _on_start() is called
   - Then _current_wave equals 1

2. **Orbs Needed Wave 1**
   - Given a SurvivalMode instance at wave 1
   - When _get_orbs_needed() is called
   - Then it returns 5

3. **Orbs Needed Wave 3**
   - Given a SurvivalMode instance at wave 3
   - When _get_orbs_needed() is called
   - Then it returns 9

4. **Spawn Interval Wave 1**
   - Given a SurvivalMode instance at wave 1
   - When _get_spawn_interval() is called
   - Then it returns 2.0

5. **Spawn Interval Wave 5**
   - Given a SurvivalMode instance at wave 5
   - When _get_spawn_interval() is called
   - Then it returns 1.6

6. **Wave Advancement**
   - Given a SurvivalMode instance at wave 1 with 4 orbs collected
   - When collecting 1 more orb (total 5)
   - Then _current_wave equals 2

7. **Final Score**
   - Given a SurvivalMode instance at wave 7
   - When _get_final_score() is called
   - Then it returns 7

8. **Metric Format**
   - Given a SurvivalMode instance at wave 3
   - When _get_metric() is called
   - Then it returns {"name": "wave", "value": 3, "max": 0}

9. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 8 tests in test_survival_mode.gd pass

10. **Demo Works**
    - Given Survival mode is selected
    - When collecting orbs and advancing waves
    - Then wave counter increases and spawn rate accelerates

## Metadata
- **Complexity**: Medium
- **Labels**: modes, waves, progression
- **Required Skills**: GDScript, Game Logic
