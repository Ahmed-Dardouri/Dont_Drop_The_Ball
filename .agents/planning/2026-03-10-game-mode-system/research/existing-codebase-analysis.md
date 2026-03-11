# Existing Codebase Analysis

## Current Architecture

### Singletons (Autoloads)
1. **GameState** (`scripts/core/game_state.gd`)
   - `is_paused: bool` with `pause_changed` signal
   - `current_mode: Enums.GameMode` with `mode_changed` signal
   - Modes: MENU, PLAYING, PAUSED, GAME_OVER
   - `reset()` method to clear state

2. **ScoreManager** (`scripts/core/score_manager.gd`)
   - `_current_score: int` with `score_changed` signal
   - `_high_score: int` with `high_score_changed` signal
   - `add_score(amount)`, `reset_score()`, `set_high_score()`

3. **EffectManager** (`scripts/effect_manager.gd`)
   - Manages timed effects: score_multiplier, slow_fall, time_slow, combo_chain, double_value, sticky_head
   - Stacking rules: multiplicative ceiling, multiplicative floor, increment
   - Clears on game over

4. **Events** (dynamic_event_manager addon)
   - Event-based communication between systems
   - Key events: PauseEvent, GameOverEvent, ButtonEvent, MoveEvent, ReplayEvent

### Scene Hierarchy
```
main.tscn
├── world_builder (world_builder.tscn)
│   ├── game_over_screen
│   ├── pause_screen
│   ├── HUD
│   └── [game objects]
├── main_menu
└── settings_menu
```

### Game Flow
1. Game starts at main_menu (paused)
2. Play button → reloads world_builder → unpauses
3. Ball hits ground → GameOverEvent → game_over_screen
4. Replay → ReplayEvent → reload world_builder
5. Back to menu → pauses game

### Current Game Over Logic
- Located in `ball.gd:_on_body_entered()`
- Triggers when ball enters "ground" group
- Calls `GameOverEvent.invoke()` and `PauseEvent.invoke(true)`
- Plays game over sound

### Orb System
- **OrbData**: Resource defining orb properties (display_name, texture, base_score, lifespan, rarity, behaviors)
- **OrbBehavior**: Abstract base for orb effects (execute, process, on_spawn)
- **GenericOrb**: Scene that can use either OrbData or legacy OrbProps
- **OrbSpawner**: Spawns orbs from configured pool on interval

### UI Elements
- HUD: Contains button_controls
- game_over_screen: Shows final score, replay/main menu buttons
- pause_screen: Resume/main menu buttons

## What Needs Generalization for Game Modes

### Currently Hardcoded
1. **Game Over Condition**: Ball hitting ground (in `ball.gd`)
2. **No Win Condition**: Endless mode only
3. **Scoring**: Simple additive scoring, no mode variants
4. **Orb Pool**: Same orbs for all play
5. **UI**: No timer display, no objective display

### Required Extractions
1. **Mode Configuration**: Need a `GameModeConfig` resource or similar
2. **Win/Lose Conditions**: Extract from `ball.gd` into mode-specific handlers
3. **Scoring Rules**: Make scoring strategy pluggable
4. **UI State**: Add mode-specific HUD elements (timer, objectives)
5. **Orb Pool Selection**: Allow modes to specify which orbs spawn

### Existing Enums
- `Enums.GameMode`: MENU, PLAYING, PAUSED, GAME_OVER (rename to `PlayState`?)
- Need new enum for actual game modes (ENDLESS, TIME_ATTACK, ORB_HUNT, etc.)

## Technical Considerations

### Signals to Add
- `mode_started(mode_id)`
- `mode_completed(mode_id, result)`
- `objective_updated(current, target)`

### Files to Modify
- `ball.gd`: Extract game over logic to mode handler
- `world_builder.gd`: Add mode initialization
- `hud.gd`: Add mode-specific UI updates
- `main_menu.gd`: Add mode selection

### New Files Needed
- `scripts/data/game_mode_config.gd`: Mode configuration resource
- `scripts/core/mode_manager.gd`: Mode orchestration
- `scripts/modes/`: Directory for mode implementations
