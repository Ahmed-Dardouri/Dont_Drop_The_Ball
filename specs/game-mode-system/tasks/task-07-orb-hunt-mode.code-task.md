---
status: pending
created: 2026-03-11
started: null
completed: null
---
# Task: Orb Hunt Mode

## Description
Implement the Orb Hunt game mode where players must collect a target score from specific orb types. Only designated orbs count toward the goal, adding a strategic element to orb selection.

## Background
Orb Hunt introduces targeted collection gameplay. Players must collect specific orb types to reach a target score. The mode needs to filter orb collections, track progress toward the goal, and display progress percentage in the HUD. This requires mode-specific metadata in the config.

## Reference Documentation
**Required:**
- Design: specs/game-mode-system/design.md (Section 3.4 Concrete Modes - OrbHuntMode)

**Additional References:**
- specs/game-mode-system/context.md (Mode Implementation Details - OrbHuntMode)
- specs/game-mode-system/plan.md (Step 7 details)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/modes/orb_hunt_mode.gd` extending ModeBase
2. Implement target tracking:
   - `_target_orb_names: Array[String]` - names of orbs that count
   - `_target_score: int` - score needed to win
   - `_current_progress: int` - accumulated score from target orbs
3. Implement orb filtering in `_on_orb_collected()`:
   - If orb name in target list: add score to progress, return base_score
   - If orb not in target list: return 0 (no score, no progress)
4. `_check_win()` returns true when `_current_progress >= _target_score`
5. Metric format: `{"name": "progress", "value": int, "max": _target_score}`
6. Load config metadata for target_orb_names and target_score
7. Create `resources/modes/orb_hunt_mode.tres` with:
   - mode_id: "orb_hunt"
   - display_name: "Orb Hunt"
   - description: "Collect target orbs to win!"
   - has_win: true
   - hud_metric: "progress"
   - implementation: reference to orb_hunt_mode.gd

## Dependencies
- Task 03: ModeBase and EndlessMode (needs ModeBase)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_orb_hunt_mode.gd` with test cases:
     - test_target_orb_scores
     - test_non_target_orb_ignored
     - test_win_at_target
     - test_progress_metric
2. **Implement minimal code to pass**
   - Create OrbHuntMode with target filtering
   - Create orb_hunt_mode.tres resource
3. **Refactor while keeping tests green**
   - Ensure config metadata loads correctly
   - Handle edge cases (empty target list, zero target score)

## Acceptance Criteria

1. **Target Orb Scores**
   - Given an OrbHuntMode with target_orb_names = ["gold_orb"]
   - When _on_orb_collected(gold_orb_data, 10) is called
   - Then score is added to _current_progress and 10 is returned

2. **Non-Target Orb Ignored**
   - Given an OrbHuntMode with target_orb_names = ["gold_orb"]
   - When _on_orb_collected(silver_orb_data, 10) is called
   - Then _current_progress is unchanged and 0 is returned

3. **Win At Target**
   - Given an OrbHuntMode with _target_score = 100 and _current_progress = 100
   - When _check_win() is called
   - Then it returns true

4. **Progress Metric**
   - Given an OrbHuntMode with _current_progress = 50 and _target_score = 100
   - When _get_metric() is called
   - Then it returns {"name": "progress", "value": 50, "max": 100}

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests in test_orb_hunt_mode.gd pass

6. **Demo Works**
   - Given Orb Hunt mode is selected
   - When collecting target orbs until goal reached
   - Then win screen appears with victory message

## Metadata
- **Complexity**: Medium
- **Labels**: modes, filtering, win-condition
- **Required Skills**: GDScript, Array Filtering
