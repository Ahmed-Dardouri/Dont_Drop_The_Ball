---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Time Attack Mode

## Description
Implement the Time Attack game mode where players must survive for 120 seconds. The mode has a win condition (time expires) and displays a countdown timer as the HUD metric.

## Background
Time Attack is the first mode with a win condition. It introduces timer-based gameplay where surviving is the goal rather than score accumulation. The mode needs to track remaining time, decrement it during _on_process, and automatically end with win=true when time reaches zero.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 3.4 Concrete Modes - TimeAttackMode)

**Additional References:**
- specs/game-mode-system/context.md (Mode Implementation Details - TimeAttackMode)
- specs/game-mode-system/plan.md (Step 6 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/modes/time_attack_mode.gd` extending ModeBase
2. Implement timer logic:
   - `_time_remaining: float` starting at 120.0 seconds
   - `_on_start()` initializes timer
   - `_on_process(delta)` decrements timer
   - `_check_win()` returns true when `_time_remaining <= 0`
3. Auto-end mode when time expires:
   - Call `ModeManager.end_mode({"win": true})` when timer reaches zero
4. Metric format: `{"name": "timer", "value": float, "max": 120.0}`
5. Create `resources/modes/time_attack_mode.tres` with:
   - mode_id: "time_attack"
   - display_name: "Time Attack"
   - description: "Survive for 2 minutes!"
   - has_win: true
   - hud_metric: "timer"
   - implementation: reference to time_attack_mode.gd

## Dependencies
- Task 03: ModeBase and EndlessMode (needs ModeBase)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_time_attack_mode.gd` with test cases:
     - test_initial_time
     - test_process_decrements
     - test_check_win_at_zero
     - test_check_win_not_zero
     - test_get_metric
     - test_auto_end_on_time_up
2. **Implement minimal code to pass**
   - Create TimeAttackMode with timer logic
   - Create time_attack_mode.tres resource
3. **Refactor while keeping tests green**
   - Ensure timer is frame-rate independent
   - Handle edge cases (negative delta, etc.)

## Acceptance Criteria

1. **Initial Time**
   - Given a TimeAttackMode instance
   - When _on_start() is called
   - Then _time_remaining equals 120.0

2. **Process Decrements**
   - Given a TimeAttackMode instance with _time_remaining = 120.0
   - When _on_process(1.0) is called
   - Then _time_remaining equals 119.0

3. **Win At Zero**
   - Given a TimeAttackMode instance with _time_remaining = 0
   - When _check_win() is called
   - Then it returns true

4. **No Win Before Zero**
   - Given a TimeAttackMode instance with _time_remaining = 60
   - When _check_win() is called
   - Then it returns false

5. **Metric Format**
   - Given a TimeAttackMode instance with _time_remaining = 90
   - When _get_metric() is called
   - Then it returns {"name": "timer", "value": 90.0, "max": 120.0}

6. **Auto End On Time Up**
   - Given a TimeAttackMode instance with _time_remaining <= 0
   - When _on_process() is called
   - Then ModeManager.end_mode is called with win=true

7. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 6 tests in test_time_attack_mode.gd pass

8. **Demo Works**
   - Given Time Attack mode is selected
   - When playing for 2 minutes
   - Then win screen appears when timer reaches zero

## Metadata
- **Complexity**: Medium
- **Labels**: modes, timer, win-condition
- **Required Skills**: GDScript, Timer Logic
