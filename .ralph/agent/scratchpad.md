# Scratchpad - Game Mode System Implementation

## 2026-03-10 Iteration: Design Synthesis Complete

### Context
- Event: requirements.complete - 12-step implementation plan complete
- Event: design.start - Implement the game mode system
- Active Hat: Architect

### Work Completed This Iteration

1. **Synthesized Design Documents**
   - Created `specs/game-mode-system/requirements.md` - Consolidated requirements from planning
   - Created `specs/game-mode-system/design.md` - Full architecture with Mermaid diagrams

2. **Created Implementation Tasks (12 steps)**
   - Step 1: Mode Data Foundation (READY)
   - Step 2: ModeManager Singleton Core (blocked by Step 1)
   - Step 3: ModeBase and EndlessMode (blocked by Step 1)
   - Step 4: Integrate ModeManager with Game Flow (blocked by 2,3)
   - Step 5: Mode Selection UI (blocked by 2)
   - Step 6: Time Attack Mode (blocked by 3)
   - Step 7: Orb Hunt Mode (blocked by 3)
   - Step 8: Survival Mode (blocked by 3)
   - Step 9: Mode-Specific Orb Pools (blocked by 4)
   - Step 10: High Score Persistence (blocked by 4)
   - Step 11: HUD Mode Display (blocked by 4)
   - Step 12: Final Integration (blocked by 5-11)

### Architecture Summary

**New Components:**
- ModeManager (singleton) - orchestrates mode lifecycle
- ModeConfig (resource) - editor-configurable mode properties
- ModeBase (abstract) - lifecycle hooks for mode implementations
- 4 concrete modes: EndlessMode, TimeAttackMode, OrbHuntMode, SurvivalMode

**Modified Files:**
- saved_game.gd - add mode_high_scores
- ball.gd - extract game over trigger
- main_menu.gd - add mode selection
- hud.gd - add mode badge/metric
- world_builder.gd - integrate with ModeManager
- orb_spawner.gd - support mode-specific orb pools

### Implementation Plan Reference
`.agents/planning/2026-03-10-game-mode-system/implementation/plan.md`

---

## 2026-03-10 Iteration: Design Critic Review

### Context
- Event: design.drafted - Review game-mode-system design
- Active Hat: Design Critic

### Codebase Analysis Performed

Reviewed existing patterns to validate design feasibility:
- `scripts/core/game_state.gd` - Has existing `current_mode: Enums.GameMode` property
- `scripts/core/score_manager.gd` - Score singleton pattern, matches proposed ModeManager pattern
- `scripts/events/*.gd` - Event system uses `class_name Event extends RefCounted` with static `invoke()`
- `scripts/data/orb_data.gd` - Resource pattern, matches proposed ModeConfig pattern
- `scripts/orb_spawner.gd` - Already has `orb_data_array: Array[OrbData]`, clean integration point
- `scripts/world_builder.gd` - Scene switching via Enums.WorldScene, clean integration point
- `scripts/ball.gd` - Game over via `GameOverEvent.invoke()`, clean integration point
- `scripts/utils/saved_game.gd` - Simple Resource with @export vars, clean extension point

### Design Review Checklist

**Completeness**
- [PASS] All functional requirements (FR-1 through FR-7) are addressed
- [CONCERN] FR-4 Orb Hunt: `target_orb_names` and `target_score` are not shown in ModeConfig schema - implementation plan shows loading from "config metadata" but ModeConfig doesn't have these fields
- [PASS] Error handling table in Section 6 is specific
- [PASS] Edge cases have strategies (save migration, empty orb pool fallback)

**Feasibility**
- [CONCERN] **GameState vs ModeManager collision**: Existing `GameState.current_mode: Enums.GameMode` conflicts with proposed `ModeManager.current_mode: ModeConfig`. Design doesn't clarify relationship - should ModeManager replace, wrap, or coexist with GameState's mode tracking?
- [PASS] Event system pattern matches existing codebase
- [PASS] Resource pattern matches existing OrbData
- [PASS] Integration points are realistic

**Simplicity (YAGNI/KISS)**
- [PASS] No speculative features
- [CONCERN] Two mode-tracking singletons could be simplified - consider ModeManager using GameState's existing mode_changed signal
- [PASS] ModeBase abstraction is justified

**Testability**
- [PASS] Unit test strategy is specific with named test files
- [PASS] Integration tests cover key flows
- [PASS] E2E scenario defined

**Clarity**
- [CONCERN] GameState.current_mode relationship to ModeManager.current_mode is ambiguous
- [PASS] Architecture diagrams match text
- [PASS] Implementation steps are clear

### Decision: APPROVED (with noted concern)

The design is fundamentally sound. The identified concern about GameState/ModeManager mode tracking can be resolved during implementation without blocking work:

**Resolution guidance for Step 4:**
- Option A: Deprecate `GameState.current_mode` in favor of `ModeManager.current_mode`
- Option B: Keep `GameState.current_mode` for mode enum (MENU/PLAYING/etc) and use `ModeManager` for mode-specific config only
- Option C: ModeManager wraps GameState, setting GameState.current_mode when mode changes

Recommend Option A or B based on team preference. The existing `Enums.GameMode.MENU/PLAYING` distinction may still be useful for pause/menu logic.

### Next Step
Emit design.approved to hand off to Explorer for codebase research.

---

## 2026-03-11 Iteration: Explorer Research Complete

### Context
- Event: design.approved - game-mode-system approved with GameState concern
- Active Hat: Explorer

### Work Completed This Iteration

1. **Researched Existing Patterns** (`specs/game-mode-system/research/existing-patterns.md`)
   - Documented singleton pattern (GameState, ScoreManager)
   - Documented resource pattern (OrbData, SavedGame)
   - Documented event system pattern (Event extends RefCounted)
   - Documented orb spawning integration points
   - Documented world builder / scene management

2. **Identified Broken Windows** (`specs/game-mode-system/research/broken-windows.md`)
   - Inconsistent naming in saved_game.gd (defer - breaking change)
   - Score system inconsistency: Variables vs ScoreManager (standardize on ScoreManager)
   - Dead code comments in ball.gd, hud.gd, main_menu.gd (fix if touching)

3. **Created Implementation Context** (`specs/game-mode-system/context.md`)
   - Resolved GameState vs ModeManager: **Option B (Coexistence)**
     - GameState.current_mode = game STATE (menu/playing/paused)
     - ModeManager.current_mode = play MODE config (endless/time_attack/etc)
   - Documented 6 integration points with code references
   - Listed enums to add (PlayMode, MainButtonType.SELECT_MODE)
   - Specified file structure to create
   - Documented constraints and testing requirements

### Key Findings

**GameState/ModeManager Resolution:**
The `Enums.GameMode` enum is misnamed - it represents game STATE (MENU/PLAYING/PAUSED/GAME_OVER), not game PLAY MODE. Keep both systems:
- `GameState.current_mode: Enums.GameMode` for pause/menu logic
- `ModeManager.current_mode: ModeConfig` for gameplay rules

**Score System Inconsistency:**
`Variables.current_score` and `ScoreManager` both track score. Mode system must use ScoreManager consistently. Update `game_over_screen.gd` to use `ScoreManager.get_score()`.

**Integration Points Identified:**
1. `world_builder.gd:load_world()` - mode initialization
2. `ball.gd:_on_body_entered()` - game over via GameOverEvent
3. `world_builder.gd:replay_button_handle()` - mode restart via ReplayEvent
4. `orb_spawner.gd:_spawn_from_props()` - mode-specific orb pools
5. `game_over_screen.gd:handle_game_over()` - high score update
6. `saved_game.gd` - add mode_high_scores field

### Research Files Created
- `specs/game-mode-system/research/existing-patterns.md`
- `specs/game-mode-system/research/broken-windows.md`
- `specs/game-mode-system/context.md`

### Next Step
Emit context.ready to hand off to Planner for test strategy and incremental implementation plan.

---

## 2026-03-11 Iteration: Planner Test Strategy Complete

### Context
- Event: context.ready - game-mode-system research complete
- Active Hat: Planner

### Work Completed This Iteration

1. **Created Comprehensive Test Strategy** (`specs/game-mode-system/plan.md`)
   - 6 unit test files with 30+ specific test cases
   - 3 integration test files with 11 test cases
   - Each test case has input and expected output defined

2. **Defined E2E Scenario**
   - Time Attack Mode complete playthrough
   - 9 step-by-step user actions with expected outcomes
   - Covers: mode selection → gameplay → win condition → high score persistence

3. **Specified TDD Implementation Order**
   - 12 steps in dependency order
   - Each step has: files, tests, demo description
   - Success criteria defined for each step and overall

### Test Strategy Summary

**Unit Tests (30+ cases):**
- ModeConfig: validation, loading
- ModeManager: lifecycle, signals
- EndlessMode: default behavior
- TimeAttackMode: timer logic, win condition
- OrbHuntMode: target filtering, progress
- SurvivalMode: wave progression, difficulty

**Integration Tests (11 cases):**
- Mode transitions (start/end/replay)
- Orb spawner pool override
- High score persistence

**E2E Scenario:**
Time Attack complete playthrough with 9 verification steps

### Key Design Decisions
- Tests written before implementation (TDD)
- Each step must pass tests AND have demoable functionality
- No orphaned code - every step integrates

### Next Step
Emit plan.ready to hand off to Task Writer for structured code task files.

---

## 2026-03-11 Iteration: Task Writer Complete

### Context
- Event: plan.ready - test strategy and 12-step TDD order defined
- Active Hat: Task Writer

### Work Completed This Iteration

1. **Created Code Task Directory**
   - `specs/game-mode-system/tasks/` - directory for code task files

2. **Created 12 Code Task Files**
   Each file follows the exact format with:
   - YAML frontmatter (status, dates)
   - Description and Background
   - Reference Documentation links
   - Technical Requirements
   - Dependencies
   - TDD Implementation Approach
   - Given-When-Then Acceptance Criteria
   - Metadata (complexity, labels, skills)

   **Tasks Created:**
   - task-01-mode-data-foundation.code-task.md (ModeConfig resource)
   - task-02-mode-manager-singleton.code-task.md (ModeManager autoload)
   - task-03-mode-base-and-endless.code-task.md (ModeBase abstract + EndlessMode)
   - task-04-integrate-mode-manager-game-flow.code-task.md (Event integration)
   - task-05-mode-selection-ui.code-task.md (Mode selection screen)
   - task-06-time-attack-mode.code-task.md (Timer-based mode)
   - task-07-orb-hunt-mode.code-task.md (Target orb collection)
   - task-08-survival-mode.code-task.md (Wave progression)
   - task-09-mode-specific-orb-pools.code-task.md (Orb spawner integration)
   - task-10-high-score-persistence.code-task.md (Save/load scores)
   - task-11-hud-mode-display.code-task.md (Mode badge + metrics)
   - task-12-final-integration-polish.code-task.md (E2E verification)

### Task Dependencies Graph

```
Task 01 (Mode Data)
    ├── Task 02 (ModeManager)
    │       └── Task 04 (Game Flow Integration)
    │               ├── Task 09 (Orb Pools)
    │               ├── Task 10 (High Scores)
    │               └── Task 11 (HUD Display)
    │                       └── Task 12 (Final Polish)
    │
    └── Task 03 (ModeBase + Endless)
            ├── Task 06 (Time Attack)
            ├── Task 07 (Orb Hunt)
            └── Task 08 (Survival)
                    └── Task 12 (Final Polish)

Task 02 (ModeManager)
    └── Task 05 (Mode Selection UI)
            └── Task 12 (Final Polish)
```

### Next Step
Emit tasks.ready to hand off to Builder for TDD implementation.

---

## 2026-03-11 Iteration: Builder Step 1 Complete

### Context
- Event: tasks.ready - 12 code tasks ready
- Active Hat: Builder

### Work Completed This Iteration

1. **TDD Cycle: Mode Data Foundation**
   - RED: Created `tests/unit/test_mode_config.gd` with 14 test cases (failed - ModeConfig didn't exist)
   - GREEN: Implemented `scripts/data/mode_config.gd` and `resources/modes/endless_mode.tres`
   - REFACTOR: Code follows OrbData pattern, uses region comments

2. **Files Created**
   - `scripts/data/mode_config.gd` - ModeConfig Resource class with:
     - Identity properties: mode_id, display_name, description, icon
     - Implementation properties: implementation (GDScript), orb_pool
     - Gameplay properties: spawn_interval, max_orbs, hud_metric, has_win
     - Validation: is_valid() method
   - `resources/modes/endless_mode.tres` - Endless mode configuration
   - `tests/unit/test_mode_config.gd` - 17 unit tests
   - `specs/game-mode-system/progress.md` - Progress tracking

3. **Test Results**
   - All 284 tests pass (including 17 new mode_config tests)
   - Smoke test passes

### Next Step
Close task-1773183307-8cde and emit task.complete. Step 2 (ModeManager) and Step 3 (ModeBase) are now unblocked.

---

## 2026-03-11 Iteration: Builder Step 2 Complete

### Context
- Event: task.complete - Step 1 (Mode Data Foundation) complete
- Active Hat: Builder

### Work Completed This Iteration

1. **TDD Cycle: ModeManager Singleton Core**
   - RED: Created `tests/unit/test_mode_manager.gd` with 12 test cases
   - GREEN: Implemented `scripts/core/mode_manager.gd` autoload singleton
   - REFACTOR: Removed class_name to avoid shadowing autoload global

2. **Files Created**
   - `scripts/core/mode_manager.gd` - ModeManager autoload with:
     - Signals: mode_started, mode_ended, metric_updated
     - Properties: current_mode, _available_modes, _high_scores
     - Methods: start_mode, end_mode, get_mode_config, get_current_metric, get_high_score, set_high_score
     - Auto-loads mode configs from resources/modes/ in _ready()
   - `tests/unit/test_mode_manager.gd` - 12 unit tests

3. **Files Modified**
   - `project.godot` - Added ModeManager to autoloads section

4. **Key Decision**
   - Did NOT use `class_name ModeManager` to avoid shadowing the autoload global name
   - Follows existing singleton pattern (GameState, ScoreManager)

5. **Test Results**
   - All 296 tests pass (including 12 new mode_manager tests)
   - Smoke test passes

### Next Step
Emit task.complete. Step 3 (ModeBase and EndlessMode) is now ready.

---

## 2026-03-11 Iteration: Builder Step 3 Complete

### Context
- Event: task.complete - Step 2 (ModeManager Singleton Core) complete
- Active Hat: Builder

### Work Completed This Iteration

1. **TDD Cycle: ModeBase and EndlessMode**
   - RED: Created `tests/unit/test_endless_mode.gd` with 22 test cases
   - GREEN: Implemented `scripts/modes/mode_base.gd` and `scripts/modes/endless_mode.gd`
   - REFACTOR: Updated ModeManager to instantiate mode implementations

2. **Files Created**
   - `scripts/modes/mode_base.gd` - Abstract base class with:
     - Lifecycle hooks: _on_start, _on_process, _on_orb_collected, _check_win, _check_lose, _on_end
     - Metric access: _get_metric, _get_final_score
     - config property for ModeConfig reference
   - `scripts/modes/endless_mode.gd` - EndlessMode implementation:
     - No win/lose conditions (game over handled by GameOverEvent)
     - Passthrough orb collection (returns base_score unchanged)
     - Score-based metric
   - `tests/unit/test_endless_mode.gd` - 22 unit tests

3. **Files Modified**
   - `scripts/core/mode_manager.gd` - Added mode implementation instantiation:
     - Added `_mode_impl: ModeBase` property
     - Added `_process()` to call `_on_process()` on mode impl
     - Added `_instantiate_mode_implementation()` method
     - Added `get_mode_implementation()` method
     - Updated `start_mode()` to instantiate implementation
     - Updated `end_mode()` to call `_on_end()` and cleanup
     - Updated `get_current_metric()` to use mode impl's `_get_metric()`
   - `resources/modes/endless_mode.tres` - Added implementation script reference

4. **Test Results**
   - All 318 tests pass (22 new tests added)
   - Smoke test passes

5. **Demo Verification**
   - ModeManager can successfully instantiate EndlessMode
   - Mode implementation is correctly associated with config

### Next Step
Emit task.complete. Step 4 (Integrate ModeManager with Game Flow) and Steps 6-8 (other mode implementations) are now unblocked.
