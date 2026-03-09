# Requirements: AI-Friendly Godot Game Refactor

## Q1: What GameMode enum values should be defined?

### Answer

Based on codebase analysis of existing state patterns, the `GameMode` enum should have these values:

```gdscript
enum GameMode {
    MENU,       # Main menu, settings, tutorial screens
    PLAYING,    # Active gameplay (ball in play)
    PAUSED,     # Pause screen overlay active
    GAME_OVER   # Game ended (ball hit ground)
}
```

### Rationale

1. **MENU**: Default state (as shown in plan). Covers MainScene values (MAIN_MENU, SETTINGS_MENU, TUTORIAL).

2. **PLAYING**: Active gameplay state. Corresponds to `WorldScene.GAME` when game is running.

3. **PAUSED**: When pause screen is visible. Replaces `PauseEvent.state` boolean - this is a distinct mode, not just a boolean toggle.

4. **GAME_OVER**: When game has ended (ball hit ground). Aligns with existing `GameOverEvent` and `WorldScene.GAME_OVER_SCREEN`.

### Mapping to Existing Code

| New GameMode | Existing Pattern |
|--------------|------------------|
| MENU | MainScene values (MAIN_MENU, etc.) |
| PLAYING | WorldScene.GAME, PauseEvent.state == false |
| PAUSED | PauseEvent.state == true, WorldScene.PAUSE_SCREEN |
| GAME_OVER | GameOverEvent invoked, WorldScene.GAME_OVER_SCREEN |

### Default Value

`MENU` is the correct default because:
- Game starts at main menu
- Matches plan specification
- Safe initial state for new game sessions

---

## Status

- [x] Q1 asked: What GameMode enum values should be defined?
- [x] Q1 answered: GameMode enum values defined (MENU, PLAYING, PAUSED, GAME_OVER)
- [x] Answer accepted by Inquisitor
- [x] Requirements complete - implementation can proceed
