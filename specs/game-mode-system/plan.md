# Game Mode System - Test Strategy & Implementation Plan

## Overview

This document provides the complete test strategy and implementation plan for the game mode system. It follows TDD principles with tests written before or alongside implementation.

---

## 1. Test Strategy

### 1.1 Unit Tests

#### test_mode_config.gd
| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| test_default_values | New ModeConfig() | mode_id="", display_name="", orb_pool=[] |
| test_resource_load | load("res://resources/modes/endless_mode.tres") | Valid ModeConfig resource |
| test_validation_valid | mode_id="endless", display_name="Endless" | is_valid() returns true |
| test_validation_empty_id | mode_id="" | is_valid() returns false |

#### test_mode_manager.gd
| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| test_initial_state | New session | current_mode == null |
| test_start_mode | start_mode("endless") | current_mode.mode_id == "endless", mode_started emitted |
| test_start_invalid_mode | start_mode("nonexistent") | Warning logged, no state change |
| test_end_mode | After start, end_mode({"win": false}) | current_mode == null, mode_ended emitted |
| test_get_mode_config | get_mode_config("endless") | Returns valid ModeConfig |
| test_get_mode_config_invalid | get_mode_config("fake") | Returns null |

#### test_endless_mode.gd
| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| test_check_win | Always | Returns false (no win condition) |
| test_check_lose | Always | Returns false (handled by GameOverEvent) |
| test_get_metric | After start | {"name": "score", "value": <current_score>} |
| test_on_orb_collected | orb_data, base_score=10 | Returns 10 (pass-through) |

#### test_time_attack_mode.gd
| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| test_initial_time | After _on_start() | _time_remaining == 120.0 |
| test_process_decrements | _on_process(1.0) | _time_remaining == 119.0 |
| test_check_win_at_zero | _time_remaining = 0 | _check_win() returns true |
| test_check_win_not_zero | _time_remaining = 60 | _check_win() returns false |
| test_get_metric | _time_remaining = 90 | {"name": "timer", "value": 90.0, "max": 120.0} |
| test_auto_end_on_time_up | _on_process with _time_remaining <= 0 | ModeManager.end_mode called with win=true |

#### test_orb_hunt_mode.gd
| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| test_target_orb_scores | orb in _target_orb_names | Score added to progress |
| test_non_target_orb_ignored | orb not in _target_orb_names | Returns 0, progress unchanged |
| test_win_at_target | _current_progress >= _target_score | _check_win() returns true |
| test_progress_metric | _current_progress=50, _target_score=100 | {"name": "progress", "value": 50, "max": 100} |

#### test_survival_mode.gd
| Test Case | Input | Expected Output |
|-----------|-------|-----------------|
| test_initial_wave | After _on_start() | _current_wave == 1 |
| test_orbs_needed_wave_1 | Wave 1 | _get_orbs_needed() == 5 |
| test_orbs_needed_wave_3 | Wave 3 | _get_orbs_needed() == 9 |
| test_spawn_interval_wave_1 | Wave 1 | _get_spawn_interval() == 2.0 |
| test_spawn_interval_wave_5 | Wave 5 | _get_spawn_interval() == 1.6 |
| test_advance_wave | Collect 5 orbs in wave 1 | _current_wave == 2 |
| test_final_score | Wave 7 | _get_final_score() == 7 |
| test_metric | Wave 3 | {"name": "wave", "value": 3, "max": 0} |

### 1.2 Integration Tests

#### test_mode_transitions.gd
| Test Case | Setup | Expected Behavior |
|-----------|-------|-------------------|
| test_game_start_initializes_mode | Load game scene | ModeManager.current_mode != null |
| test_game_over_ends_mode | Trigger GameOverEvent | mode_ended signal emitted |
| test_replay_restarts_mode | Trigger ReplayEvent | Same mode restarted, score reset |
| test_mode_switch | start_mode("time_attack") then start_mode("endless") | Only endless active |

#### test_mode_orb_spawner.gd
| Test Case | Setup | Expected Behavior |
|-----------|-------|-------------------|
| test_default_pool_no_mode | ModeManager.current_mode = null | Uses orb_spawner default pool |
| test_mode_pool_override | Mode with custom orb_pool | Uses mode's orb_pool |
| test_empty_pool_fallback | Mode with empty orb_pool | Falls back to default |

#### test_mode_high_scores.gd
| Test Case | Setup | Expected Behavior |
|-----------|-------|-------------------|
| test_new_mode_zero_score | get_high_score("new_mode") | Returns 0 |
| test_set_high_score | set_high_score("endless", 500) | Saved to SavedGame.mode_high_scores |
| test_update_only_if_higher | Score 500 exists, set 300 | Remains 500 |
| test_persistence | Set score, reload save | Score persists |

### 1.3 Test File Locations

```
tests/
├── unit/
│   ├── test_mode_config.gd
│   ├── test_mode_manager.gd
│   ├── test_endless_mode.gd
│   ├── test_time_attack_mode.gd
│   ├── test_orb_hunt_mode.gd
│   └── test_survival_mode.gd
└── integration/
    ├── test_mode_transitions.gd
    ├── test_mode_orb_spawner.gd
    └── test_mode_high_scores.gd
```

---

## 2. E2E Test Scenario

**Scenario:** Complete Time Attack Mode Playthrough

**Preconditions:**
- Game launched from clean state
- No existing high score for time_attack mode

**Steps:**

| Step | User Action | Expected Observable Outcome |
|------|-------------|----------------------------|
| 1 | Click "Play" button | Main menu appears |
| 2 | Click "Select Mode" button | Mode selection screen appears with 4 mode buttons |
| 3 | Click "Time Attack" mode | Mode selected, game scene loads |
| 4 | Observe HUD | Mode badge shows "Time Attack", timer shows "2:00" |
| 5 | Balance ball, collect orbs | Score increases, timer counts down |
| 6 | Wait 2 minutes (or accelerate time in test) | Timer reaches "0:00", win screen appears |
| 7 | Observe game over screen | Shows "Victory!", final score, high score notification |
| 8 | Click "Menu" button | Returns to main menu |
| 9 | Click "Select Mode" | Time Attack shows high score from step 7 |

**Verification Commands:**
```bash
# After implementation, run:
./devscripts/test.sh      # All unit + integration tests pass
./devscripts/smoke_test.sh # Runtime validation
```

---

## 3. Implementation Steps (TDD Order)

### Step 1: Mode Data Foundation
**Files:** `scripts/data/mode_config.gd`, `resources/modes/endless_mode.tres`
**Tests:** test_mode_config.gd (all 4 cases)
**Demo:** Load ModeConfig from .tres file, print properties

### Step 2: ModeManager Singleton Core
**Files:** `scripts/core/mode_manager.gd`, modify `project.godot`
**Tests:** test_mode_manager.gd (all 6 cases)
**Demo:** Call ModeManager.start_mode("endless") from test, verify state

### Step 3: ModeBase and EndlessMode
**Files:** `scripts/modes/mode_base.gd`, `scripts/modes/endless_mode.gd`
**Tests:** test_mode_base.gd, test_endless_mode.gd (all cases)
**Demo:** Start endless mode, verify implementation is instantiated

### Step 4: Integrate ModeManager with Game Flow
**Files:** `scripts/world_builder.gd`, `scripts/ball.gd` (minimal changes)
**Tests:** test_mode_transitions.gd (all 4 cases)
**Demo:** Play game from menu, verify mode active; drop ball, verify mode ends

### Step 5: Mode Selection UI
**Files:** `scenes/mode_selection.tscn`, `scripts/mode_selection.gd`, `scripts/main_menu.gd`
**Tests:** Manual verification + test_mode_selection.gd
**Demo:** Click mode selection, see modes, select one, game starts

### Step 6: Time Attack Mode
**Files:** `scripts/modes/time_attack_mode.gd`, `resources/modes/time_attack_mode.tres`
**Tests:** test_time_attack_mode.gd (all 6 cases)
**Demo:** Select Time Attack, play 2 minutes, see win screen

### Step 7: Orb Hunt Mode
**Files:** `scripts/modes/orb_hunt_mode.gd`, `resources/modes/orb_hunt_mode.tres`
**Tests:** test_orb_hunt_mode.gd (all 4 cases)
**Demo:** Select Orb Hunt, collect target orbs, see progress, reach goal

### Step 8: Survival Mode
**Files:** `scripts/modes/survival_mode.gd`, `resources/modes/survival_mode.tres`
**Tests:** test_survival_mode.gd (all 8 cases)
**Demo:** Select Survival, advance waves, see difficulty increase

### Step 9: Mode-Specific Orb Pools
**Files:** `scripts/orb_spawner.gd` (modify)
**Tests:** test_mode_orb_spawner.gd (all 3 cases)
**Demo:** Play Orb Hunt, verify only target orbs spawn

### Step 10: High Score Persistence
**Files:** `scripts/utils/saved_game.gd`, `scripts/game_over_screen.gd`, `scripts/core/mode_manager.gd`
**Tests:** test_mode_high_scores.gd (all 4 cases)
**Demo:** Set high score, restart game, verify persistence

### Step 11: HUD Mode Display
**Files:** `scenes/hud.tscn`, `scripts/hud.gd`
**Tests:** Manual verification of each mode's metric display
**Demo:** Play each mode, verify correct metric format

### Step 12: Final Integration and Polish
**Files:** Various (cleanup, icons, final config)
**Tests:** Full test suite run + E2E scenario
**Demo:** Complete E2E scenario without errors

---

## 4. Success Criteria

Each step is complete when:
1. All specified tests pass
2. Demo functionality works as described
3. No regressions in existing tests
4. Code follows existing patterns (see context.md)

Full implementation is complete when:
1. All 12 steps pass their success criteria
2. `./devscripts/test.sh` exits 0
3. `./devscripts/smoke_test.sh` exits 0
4. E2E scenario executes successfully
5. All 4 modes are playable with correct behavior

---

## 5. References

- Design: `specs/game-mode-system/design.md`
- Context: `specs/game-mode-system/context.md`
- Existing patterns: `specs/game-mode-system/research/existing-patterns.md`
