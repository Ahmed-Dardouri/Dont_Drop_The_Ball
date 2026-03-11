# Game Mode System - Rough Idea

## Source
Plan: `.agents/planning/2026-03-10-game-mode-system/implementation/plan.md`

## Summary
Implement a game mode system supporting multiple play modes:
- Endless Mode (current behavior, no win condition)
- Time Attack Mode (2-minute timer, win on time expire)
- Orb Hunt Mode (collect target orbs to reach score goal)
- Survival Mode (wave progression with increasing difficulty)

## Key Components
1. **ModeConfig** - Resource class defining mode properties
2. **ModeManager** - Singleton managing mode lifecycle
3. **ModeBase** - Abstract base class for mode implementations
4. **Mode-specific implementations** - EndlessMode, TimeAttackMode, OrbHuntMode, SurvivalMode
5. **Mode Selection UI** - Screen for choosing game mode
6. **Mode-specific orb pools** - Each mode can define which orbs spawn
7. **Mode-specific high scores** - Persist best scores per mode
8. **HUD updates** - Display mode badge and mode-specific metrics

## Integration Points
- `world_builder.gd` - Start default mode on game start
- `orb_spawner.gd` - Use mode-specific orb pools
- `hud.gd` - Display mode and metrics
- `main_menu.gd` - Add mode selection button
- `saved_game.gd` - Store mode-specific high scores
- `game_over_screen.gd` - Show mode-specific results

## Existing Codebase Alignment
- `ScoreManager` exists with `get_score()`, `add_score()`, `reset_score()`
- `OrbData` resource class exists with behaviors
- `OrbAdapter.create_orb_from_data()` exists
- `OrbSpawner` uses `orb_data_array: Array[OrbData]`
- Event system exists (`GameOverEvent`, `ReplayEvent`, `ButtonEvent`)
- `GameSaveMngr` and `saved_game.gd` for persistence

## Implementation Steps (12 total)
1. Mode Data Foundation
2. ModeManager Singleton Core
3. ModeBase and EndlessMode
4. Integrate ModeManager with Game Flow
5. Mode Selection UI
6. Time Attack Mode
7. Orb Hunt Mode
8. Survival Mode
9. Mode-Specific Orb Pools
10. High Score Persistence
11. HUD Mode Display
12. Final Integration and Polish
