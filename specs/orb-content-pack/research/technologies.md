# Technologies - Orb Content Pack

## Godot Version

**4.4** with Forward Plus renderer

---

## Autoload Singletons

| Name | Script | Purpose |
|------|--------|---------|
| PhantomCameraManager | `addons/phantom_camera/...` | Camera system |
| Events | `addons/dynamic_event_manager/...` | Event bus |
| Constants | `scripts/utils/Constants.gd` | Game constants |
| GameSaveMngr | `scripts/utils/game_save_mngr.gd` | Save system |
| Variables | `scripts/utils/variables.gd` | Game variables |
| GameState | `scripts/core/game_state.gd` | Game state |
| ScoreManager | `scripts/core/score_manager.gd` | Score tracking |
| EffectManager | `scripts/effect_manager.gd` | Effect management |

---

## Testing Framework

**GUT (Godot Unit Test)** - `addons/gut/`

### Test Runner
- CLI: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gexit`
- Config: `.gutconfig.json`

### Test Location
- Unit tests: `tests/unit/`
- Integration tests: `tests/integration/`

### Key Assertions
```gdscript
assert_eq(actual, expected, "message")
assert_true(condition, "message")
assert_false(condition, "message")
assert_null(value, "message")
assert_not_null(value, "message")
```

### Async Testing
```gdscript
await wait_seconds(seconds)
```

---

## Physics

- **Ball:** RigidBody2D with ShapeCast2D
- **Player:** RigidBody2D with ShapeCast2D (ground_cast, ceiling_cast)
- **Orbs:** Area2D for collision detection

---

## Resource System

Godot's Resource system for data-driven design:
- `OrbData extends Resource` - Orb definitions
- `OrbBehavior extends Resource` - Behavior definitions
- Resources saved as `.tres` files

---

## Typed GDScript

Project uses typed GDScript:
```gdscript
var max_speed := 1500.0
func _on_body_entered(body: Node) -> void
var _active_effects: Dictionary = {}
```

---

## Event System (Dynamic Event Manager)

Custom event bus pattern:
```gdscript
# Define event
class_name MyEvent extends Event
var _value: int

# Invoke
MyEvent.invoke(42)

# Listen
Events.add_listener(MyEvent, _on_my_event)
```

---

## Available Dependencies

### Built-in
- `get_tree().get_nodes_in_group("group_name")` - Scene queries
- `Engine.time_scale` - Time manipulation
- `is_in_group("group_name")` - Group membership check

### Project-specific
- `ScoreManager.add_score(amount)` - Score changes
- `EffectManager.apply_effect(...)` - Effect application
- `Constants.*` - Game constants

---

## Validation Command

```bash
./devscripts/test.sh
```

This runs:
1. `./devscripts/import.sh` - Asset import
2. `./devscripts/smoke_test.sh` - Basic validation
3. GUT tests - Unit and integration tests
