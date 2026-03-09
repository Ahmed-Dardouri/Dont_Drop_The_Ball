# Question 1: GameMode Enum Values

## Question

The implementation plan's Step 1 (Create GameState Singleton) references `Enums.GameMode.MENU` as the default value for `current_mode`:

```gdscript
var current_mode: Enums.GameMode = Enums.GameMode.MENU:
    set(value):
        if value != current_mode:
            current_mode = value
            mode_changed.emit(value)
```

However, the current `scripts/utils/enums.gd` does not contain a `GameMode` enum.

**What GameMode values should be defined?**

For example:
- MENU, PLAYING, PAUSED?
- MENU, GAME, GAME_OVER?
- Something else?

This affects the GameState singleton design and how other systems will check the current game state.
