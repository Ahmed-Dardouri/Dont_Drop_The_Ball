# Game Mode System - Implementation Context

## Summary

This document provides the Builder with all necessary context to implement the game mode system. Research was conducted by exploring existing patterns, integration points, and constraints.

---

## Critical Decision: GameState vs ModeManager Relationship

### The Conflict
The design proposes `ModeManager.current_mode: ModeConfig` but `GameState` already has `current_mode: Enums.GameMode` which represents game STATE (MENU/PLAYING/PAUSED/GAME_OVER), not game PLAY MODE (endless/time_attack/etc).

### Resolution: Option B (Coexistence)
**Keep both systems separate:**
- `GameState.current_mode: Enums.GameMode` → Game state (menu/playing/paused/game_over)
- `ModeManager.current_mode: ModeConfig` → Play mode config (endless/time_attack/orb_hunt/survival)

**Rationale:**
1. `Enums.GameMode` naming is misleading but changing it is a breaking change
2. The two serve different purposes:
   - GameState controls pause/menu logic
   - ModeManager controls gameplay rules
3. Cleanest integration without refactoring existing code

**Implementation Note:**
- When ModeManager starts a mode, it should set `GameState.current_mode = Enums.GameMode.PLAYING`
- When mode ends (game over), `GameState.current_mode = Enums.GameMode.GAME_OVER`

---

## Integration Points

### 1. Game Start (world_builder.gd:26-28)
```gdscript
func load_world():
	SoundPlayEvent.invoke(Enums.SoundType.MUSIC, Enums.Sounds.LOFI_BG_MUSIC)
	hud.visible = true
	# ADD: ModeManager.start_mode_if_none() or similar
```

**Action**: Call `ModeManager.start_mode("endless")` if no mode is set

### 2. Game Over (ball.gd:49-54)
```gdscript
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground") && !game_over:
		game_over = true
		GameOverEvent.invoke()  # ModeManager listens to this
		# ...
```

**Action**: ModeManager subscribes to `GameOverEvent` and calls `end_mode()`

### 3. Replay (world_builder.gd:84-86)
```gdscript
func replay_button_handle():
	switch_scene(Enums.WorldScene.GAME)
	ReplayEvent.invoke()  # ModeManager listens to this
```

**Action**: ModeManager subscribes to `ReplayEvent` and restarts current mode

### 4. Orb Spawning (orb_spawner.gd:44-68)
```gdscript
func _spawn_from_props() -> Node:
	# ADD: Check ModeManager for custom orb pool
	var pool_size := orb_props.size() + orb_data_array.size()
	# ...
```

**Action**: Check `ModeManager.current_mode.orb_pool` first, fallback to default

### 5. Score Tracking (game_over_screen.gd:11-19)
```gdscript
func handle_game_over(event: GameOverEvent) -> void:
	var saved_game := GameSaveMngr.get_saved_game()
	var curr_score = get_current_score()  # Uses Variables.current_score
	saved_game.pb = max(curr_score, saved_game.pb)
	# ...
```

**Action**: Extend to use `ModeManager.get_high_score(mode_id)` and `set_high_score()`

### 6. High Score Save (saved_game.gd:1-7)
```gdscript
class_name SavedGame extends Resource

@export var pb: int
@export var Sfx_volume: int
@export var Music_volume: int
# ADD: @export var mode_high_scores: Dictionary = {}
```

**Action**: Add `mode_high_scores: Dictionary` field

---

## Enums to Add

### Source: scripts/utils/enums.gd

```gdscript
# Add to Enums class:

enum PlayMode {
	ENDLESS,
	TIME_ATTACK,
	ORB_HUNT,
	SURVIVAL
}

# Add to MainButtonType:
enum MainButtonType {
	PLAY,
	SETTINGS,
	BACK,
	EXIT,
	SELECT_MODE,  # NEW
}
```

---

## Autoload Registration

### Source: project.godot

Add to [autoload] section:
```
ModeManager="*res://scripts/core/mode_manager.gd"
```

---

## File Structure to Create

```
scripts/
├── core/
│   └── mode_manager.gd (NEW - autoload)
├── data/
│   └── mode_config.gd (NEW - Resource)
├── modes/
│   ├── mode_base.gd (NEW - abstract)
│   ├── endless_mode.gd (NEW)
│   ├── time_attack_mode.gd (NEW)
│   ├── orb_hunt_mode.gd (NEW)
│   └── survival_mode.gd (NEW)

resources/modes/ (NEW directory)
├── endless_mode.tres
├── time_attack_mode.tres
├── orb_hunt_mode.tres
└── survival_mode.tres

scenes/
└── mode_selection.tscn (NEW)

scripts/
└── mode_selection.gd (NEW)
```

---

## Constraints

### 1. Score System Inconsistency
The codebase has two score tracking systems:
- `Variables.current_score` - simple variable
- `ScoreManager` - singleton with signals

**Constraint**: Mode system must use `ScoreManager` consistently. Update `game_over_screen.gd` to use `ScoreManager.get_score()` instead of `Variables.current_score`.

### 2. Event Pause Check
Events check `PauseEvent.state` before invoking:
```gdscript
static func invoke():
	if PauseEvent.state == false:
		Events.invoke(GameOverEvent.new())
```

**Constraint**: Mode events should follow same pattern

### 3. Resource Save Format
SavedGame uses `@export` properties for persistence. Adding `mode_high_scores: Dictionary` must use `@export` for serialization.

### 4. Test Pattern
All tests `extend GutTest` with `before_each()` and `after_each()` for setup/cleanup. Disconnect signals in `after_each()`.

### 5. Godot 4.4 Syntax
Project uses Godot 4.4 with typed GDScript. Use:
- `@export var array: Array[Type] = []`
- `@onready var node: NodeType = $Path`
- Signal connections with `.connect(callback)`

---

## Mode Implementation Details

### EndlessMode
- No win condition
- Lose on ball drop (via GameOverEvent)
- Metric: current score from ScoreManager

### TimeAttackMode
- Win: survive 120 seconds
- Lose: ball drop before time
- Timer decrements in `_on_process(delta)`
- Calls `ModeManager.end_mode({"win": true})` when time expires
- Metric: remaining time

### OrbHuntMode
- Win: reach target score from specific orb types
- Lose: ball drop
- Needs config metadata for `target_score` and `target_orb_names`
- `_on_orb_collected()` filters by orb type
- Metric: progress percentage

### SurvivalMode
- Endless waves of increasing difficulty
- Lose on ball drop
- Wave advances after X orbs collected
- Difficulty: spawn interval decreases, orbs needed increases
- Metric: current wave number
- Final score = wave number (not cumulative score)

---

## Testing Requirements

### Unit Tests (tests/unit/)
- `test_mode_config.gd` - Config loading, validation
- `test_mode_manager.gd` - Mode lifecycle, high scores
- `test_endless_mode.gd` - Default behavior
- `test_time_attack_mode.gd` - Timer logic
- `test_orb_hunt_mode.gd` - Target filtering
- `test_survival_mode.gd` - Wave progression

### Integration Tests (tests/integration/)
- `test_mode_transitions.gd` - Start/end/replay flow
- `test_mode_orb_spawner.gd` - Pool override
- `test_mode_high_scores.gd` - Persistence

### Verification
```bash
./devscripts/test.sh      # Unit + integration tests
./devscripts/smoke_test.sh # Runtime validation
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing gameplay | Extensive integration tests in Step 4 |
| Save file migration | Initialize `mode_high_scores` to `{}` if missing |
| Score system confusion | Standardize on ScoreManager throughout |
| GameState naming collision | Keep systems separate (see Critical Decision) |

---

## Reference Files

- Design: `specs/game-mode-system/design.md`
- Requirements: `specs/game-mode-system/requirements.md`
- Plan: `.agents/planning/2026-03-10-game-mode-system/implementation/plan.md`
- Patterns: `specs/game-mode-system/research/existing-patterns.md`
- Broken Windows: `specs/game-mode-system/research/broken-windows.md`
