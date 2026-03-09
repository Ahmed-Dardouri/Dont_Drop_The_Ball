# Implementation Context

## Summary

This document provides implementation context for the AI-Friendly Godot Game Refactor. The design has been approved and this context file synthesizes research findings to enable the Builder to proceed.

---

## Key Decisions from Requirements Phase

### GameMode Enum Values (Q1)
```gdscript
enum GameMode {
    MENU,       # Main menu, settings, tutorial screens
    PLAYING,    # Active gameplay (ball in play)
    PAUSED,     # Pause screen overlay active
    GAME_OVER   # Game ended (ball hit ground)
}
```
- Default: `MENU`
- File to add: `scripts/utils/enums.gd`

---

## Integration Points

### Autoloads (project.godot:18-24)
| Name | Path | Note |
|------|------|------|
| PhantomCameraManager | addons/phantom_camera/... | Camera system |
| Events | addons/dynamic_event_manager/src/event_manager.gd | Event bus |
| Constants | scripts/utils/Constants.gd | Physics constants (to migrate) |
| GameSaveMngr | scripts/utils/game_save_mngr.gd | Save/load |
| Variables | scripts/utils/variables.gd | Runtime state |

**New Autoloads to Add:**
- `GameState` → `scripts/core/game_state.gd`
- `ScoreManager` → `scripts/core/score_manager.gd`

### Event Flow (Current)
```
Orb collision → OrbCollectedEvent → orb_mngr.gd → AddScoreEvent → score_mngr.gd
```

### Event Flow (Target)
```
Orb collision → Orb.collect() → ScoreManager.add_score() → score_changed signal → UI
```

---

## Collision Migration Details

### Current Implementation (Hardcoded Names)
| File | Line | Check | Target Node |
|------|------|-------|-------------|
| ball.gd | 49 | `body.name == "ground_static"` | scenes/ground.tscn:9 |
| ball.gd | 54 | `body.name == "half_static"` | scenes/half_solid_orb.tscn:20 |
| blue_orb.gd | 25 | `body.name == "ball"` | scenes/ball.tscn:16 |
| red_orb.gd | 24 | `body.name == "ball"` | scenes/ball.tscn:16 |
| half_solid_orb.gd | 48 | `body.name == "ball"` | scenes/ball.tscn:16 |

### Target Implementation (Groups)
| Entity | Group to Add | Location |
|--------|--------------|----------|
| Ball | "ball" | ball.gd:_ready() via add_to_group() |
| Ground | "ground" | ground.tscn root node |
| HalfSolidOrb | "half_solid" or type check | half_solid_orb.gd |

---

## Physics Constants Migration

### Ball Constants (Constants.gd:24-27)
| Constant | Value | Target Config |
|----------|-------|---------------|
| ball_max_speed | 900.0 | BallPhysicsConfig.max_speed |
| ball_fall_speed | 500.0 | BallPhysicsConfig.max_fall_speed |
| ball_air_friction | 9 | BallPhysicsConfig.air_friction |

### Player Constants (Constants.gd:5-19)
| Constant | Value | Target Config |
|----------|-------|---------------|
| player_jump_power | -700 | PlayerPhysicsConfig.jump_power |
| player_initial_move_speed | 120 | PlayerPhysicsConfig.move_speed |
| player_coyote_timeout | 150.0 | PlayerPhysicsConfig.coyote_timeout |
| player_jump_buffer_timeout | 150.0 | PlayerPhysicsConfig.jump_buffer_timeout |
| player_grounding_force | 1.5 | PlayerPhysicsConfig.grounding_force |
| player_fall_acceleration | 1800.0 | PlayerPhysicsConfig.fall_acceleration |
| player_max_fall_speed | 800.0 | PlayerPhysicsConfig.max_fall_speed |
| player_Jump_ended_early_gravity_modifier | 3.0 | PlayerPhysicsConfig.early_jump_gravity_modifier |
| player_move_acceleration | 1500 | PlayerPhysicsConfig.acceleration |
| player_initial_move_acceleration | 2000 | PlayerPhysicsConfig.initial_acceleration |
| player_move_deceleration | 10000 | PlayerPhysicsConfig.deceleration |

---

## Orb Score Values (Constants.gd:32-39)

| Orb Type | Score | Lifespan |
|----------|-------|----------|
| Blue | 2 | 30s |
| Red | 3 | 30s |
| Half Solid | 8 | 18s |

---

## Constraints & Gotchas

### 1. PauseEvent Backward Compatibility
During migration, `PauseEvent.state` must remain accessible:
```gdscript
# scripts/events/pause_event.gd (transitional)
static var state: bool:
    get: return GameState.is_paused
    set(value): GameState.is_paused = value
```

### 2. World Reload Pattern
`main.gd:_reload_world()` uses multiple await frames before adding new scene. Keep this pattern intact.

### 3. GenericOrb Spawn Animation
Current implementation uses 1.5s timer with opacity fade. Plan's Orb class must preserve this behavior:
- Timer duration: 1.5 seconds
- Opacity range: 0.0 → 0.75 during spawn → 1.0 on active

### 4. Half-Solid Orb Dual Behavior
- First collision: Bounce ball (velocity /= 3)
- Second collision: Collect orb
- Uses separate Area2D for collection vs StaticBody2D for collision

### 5. Existing Group Usage
`orb_spawner.gd:24` already uses `get_tree().get_nodes_in_group("orbs")`. The "orbs" group is already established.

---

## Testing Strategy

### Test Framework
- GUT (Godot Unit Testing)
- Config: `.gutconfig.json`
- Run: `./devscripts/test.sh`

### Existing Tests (to update)
| File | Tests |
|------|-------|
| test_ball_physics.gd | clamp_max_speed, clamp_fall_speed, apply_air_friction |
| test_player_movement.gd | update_move, can_coyote, has_buffered_jump |
| test_pause_state.gd | PauseEvent.state (migrate to GameState) |

### New Tests (per plan)
| File | Coverage |
|------|----------|
| test_game_state.gd | Initial state, signals, toggle, reset |
| test_score_manager.gd | Add, reset, high score, signals |
| test_orb_registry.gd | Register, lookup, weighted random |
| test_orb.gd | Spawn animation, collect, lifetime |

---

## Module Structure (Target)

```
scripts/
├── core/                    # NEW
│   ├── game_state.gd
│   └── score_manager.gd
├── systems/
│   ├── physics/             # NEW
│   │   ├── ball_physics.gd
│   │   └── player_physics.gd
│   └── input/               # NEW
│       └── player_input_state.gd
├── entities/
│   └── orb/                 # NEW
│       ├── orb_definition.gd
│       ├── orb_registry.gd
│       ├── orb.gd
│       └── half_solid_orb.gd
├── data/                    # NEW
│   ├── ball_physics_config.gd
│   └── player_physics_config.gd
├── events/                  # EXISTING (modify)
├── utils/                   # EXISTING (modify)
└── [existing entity scripts] # MODIFY IN PLACE
```

---

## Files to Create

| Phase | File Path |
|-------|-----------|
| 1 | scripts/core/game_state.gd |
| 1 | scripts/core/score_manager.gd |
| 2 | scripts/systems/physics/ball_physics.gd |
| 2 | scripts/systems/physics/player_physics.gd |
| 2 | scripts/systems/input/player_input_state.gd |
| 2 | scripts/data/ball_physics_config.gd |
| 2 | scripts/data/player_physics_config.gd |
| 3 | scripts/entities/orb/orb_definition.gd |
| 3 | scripts/entities/orb/orb_registry.gd |
| 3 | scripts/entities/orb/orb.gd |
| 3 | scripts/entities/orb/half_solid_orb.gd |

## Files to Modify

| Phase | File Path | Changes |
|-------|-----------|---------|
| 1 | scripts/utils/enums.gd | Add GameMode enum |
| 1 | scripts/events/pause_event.gd | Delegate to GameState |
| 1 | project.godot | Add GameState, ScoreManager autoloads |
| 2 | scripts/ball.gd | Use BallPhysics class |
| 2 | scripts/physics_player.gd | Use PlayerPhysics class |
| 3 | scripts/orb_spawner.gd | Use OrbRegistry |
| 4 | scenes/ground.tscn | Add "ground" group |
| 4 | scenes/ball.tscn | Add "ball" group (via script) |

## Files to Delete (Phase 4)

| File | Reason |
|------|--------|
| scripts/blue_orb.gd | Replaced by unified Orb class |
| scripts/red_orb.gd | Replaced by unified Orb class |
| scripts/generic_orb.gd | Replaced by unified Orb class |
| scenes/blue_orb.tscn | Replaced by orb.tscn |
| scenes/red_orb.tscn | Replaced by orb.tscn |
| scenes/generic_orb.tscn | Replaced by orb.tscn |

---

## Validation Commands

```bash
# Before each commit:
./devscripts/import.sh
./devscripts/smoke_test.sh
./devscripts/test.sh

# All must exit 0
```

---

## Research Files

For detailed patterns and broken windows, see:
- `specs/ai-refactor-prep/research/existing-patterns.md`
- `specs/ai-refactor-prep/research/broken-windows.md`
