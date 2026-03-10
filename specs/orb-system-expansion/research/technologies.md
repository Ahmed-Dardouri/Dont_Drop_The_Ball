# Technologies - Orb System Expansion

## Game Engine

### Godot 4.4.1
- **Rendering:** Forward Plus
- **Resolution:** 1920x1080
- **Stretch Mode:** viewport, keep_height

### GDScript
- Typed variables required (`var name: Type`)
- `@export` for editor properties
- `@onready` for node references
- `class_name` for global type registration

---

## Addons

### Dynamic Event Manager
**Path:** `addons/dynamic_event_manager/`

Event bus pattern implementation:
- `Event` - base class for all events
- `EventManager` - singleton as `Events`
- `add_listener(event_class, callable)`
- `remove_listener(event_class, callable)`
- `invoke(event_instance)` - async with await support

### GUT (Godot Unit Testing)
**Path:** `addons/gut/`

Testing framework:
- `extends GutTest` for test files
- `before_each()`, `after_each()` lifecycle
- Assertions: `assert_eq`, `assert_true`, `assert_gt`, etc.
- `add_child_autofree()` for auto-cleanup

### Phantom Camera
**Path:** `addons/phantom_camera/`

Camera management - not directly related to orb system.

---

## Project Structure

```
scripts/
├── core/           # Singleton managers (game_state, score_manager)
├── data/           # Resource definitions (ball_physics_config, player_physics_config)
├── events/         # Event classes
├── systems/        # Physics and input systems
├── utils/          # Constants, Enums, Variables
├── [orb files]     # blue_orb.gd, red_orb.gd, etc. (to be replaced)
scenes/
├── [orb scenes]    # blue_orb.tscn, etc. (to be replaced)
sprites/
├── blue_ball.png   # Blue orb texture
├── red_ball.png    # Red orb texture
├── collect_half.png, solid_half.png  # Half-solid orb textures
tests/
├── unit/           # Unit tests
├── integration/    # Integration tests
```

---

## Available Assets

### Orb Textures
| Texture | Path | Usage |
|---------|------|-------|
| blue_ball.png | `sprites/blue_ball.png` | Blue orb |
| red_ball.png | `sprites/red_ball.png` | Red orb |
| collect_half.png | `sprites/collect_half.png` | Half-solid collect area |
| solid_half.png | `sprites/solid_half.png` | Half-solid physics body |

### New Orb Placeholder Strategy
Per design constraints: "No large asset work (placeholder sprites acceptable)"

Options for new orbs:
1. Reuse existing textures with color modulation
2. Use colored circles via code (ImageTexture)
3. Simple shape differentiation

---

## Build & Test Commands

**Source:** Design mentions `./devscripts/test.sh`

```bash
./devscripts/test.sh        # Run test suite
./devscripts/smoke_test.sh  # Smoke test
./devscripts/import.sh      # Import resources
```

---

## Constraints from Design

| Constraint | Value |
|------------|-------|
| Godot Version | 4.4.1 |
| Language | GDScript, typed |
| Effect Duration | 45s (10s for time-altering) |
| Ball bounce | Preserve unchanged |
| Score values | Preserve existing |

---

## Resource System

Resources are defined as `.gd` scripts extending `Resource`:

```gdscript
class_name MyResource extends Resource

@export var property: Type = default_value
```

Resources are saved as `.tres` files and can be:
- Created in editor
- Loaded at runtime via `load()`
- Instantiated multiple times

---

## Physics System

### Ball (RigidBody2D)
- Uses `linear_velocity` for movement
- `clamp_max_speed()`, `clamp_fall_speed()`, `apply_air_friction()`
- Group membership: `"ball"`

### Half-Solid (StaticBody2D)
- Group membership: `"half_solid"`
- Reduces ball velocity to 1/3 on collision

---

## Signal Pattern

Godot signals for reactive updates:

```gdscript
signal score_changed(new_score: int)

# Emission:
score_changed.emit(_current_score)
```

Used in ScoreManager and GameState singletons.
