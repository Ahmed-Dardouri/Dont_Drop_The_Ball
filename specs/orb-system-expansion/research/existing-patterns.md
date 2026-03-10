# Existing Patterns - Orb System Expansion

## Event System Pattern

**Source:** `addons/dynamic_event_manager/src/Event.gd`, `event_manager.gd`

### Event Definition Pattern
All events extend `Event` class and follow this structure:

```gdscript
# file: scripts/events/add_score_event.gd:1-11
class_name AddScoreEvent extends Event

var _score: int

func _init(score: int) -> void:
    _score = score

static func invoke(score: int):
    if PauseEvent.state == false:
        Events.invoke(AddScoreEvent.new(score))
```

**Key conventions:**
- Private properties prefixed with `_`
- Static `invoke()` method for triggering events
- `PauseEvent.state` check prevents events during pause
- No return value from `invoke()`

### Event Listener Pattern
**Source:** `scripts/orb_mngr.gd:5-6, 13-22`

```gdscript
func _ready() -> void:
    Events.add_listener(OrbCollectedEvent, orb_event_handler)

func orb_event_handler(event: OrbCollectedEvent):
    match event._props.Type:
        Enums.OrbType.BLUE:
            orb_event_handler_blue()
        # ...
```

**Key conventions:**
- Register listeners in `_ready()`
- Handler accepts typed event parameter
- Use `match` for event type discrimination

---

## Current Orb Architecture

### Scene Hierarchy (Composite Pattern)
**Source:** `scenes/generic_orb.tscn`, `scripts/generic_orb.gd`

```
GenericOrb (Node2D) - container/wrapper
├── Timer - spawn animation timer
└── child_orbs (Node2D)
    ├── blue_orb (BlueOrb scene instance)
    ├── red_orb (RedOrb scene instance)
    └── half_solid_orb (HalfSolidOrb scene instance)
```

### Orb Type Scripts
**Source:** `scripts/blue_orb.gd`, `scripts/red_orb.gd`, `scripts/half_solid_orb.gd`

Each orb type has a dedicated script with:
- `@onready` node references
- `_props: OrbProps` property
- `_lifespan: int` from `Constants`
- `orb_collected()` method that fires `OrbCollectedEvent`
- `set_sprite_opacity(value: float)` method
- `set_collision_enable(value: bool)` method

**Pattern from `scripts/blue_orb.gd:17-21`:**
```gdscript
func orb_collected():
    OrbCollectedEvent.invoke(_props)
    SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
    queue_free()
```

### Spawn Animation Pattern
**Source:** `scripts/generic_orb.gd:49-76`

- 1.5 second fade-in via timer
- Opacity ramps from 0 to 0.75 during spawn
- Collision disabled during spawn animation
- Timer triggers `enable_child_orb()` which sets opacity to 1.0 and enables collision

---

## Resource Pattern

**Source:** `scripts/data/ball_physics_config.gd`

```gdscript
class_name BallPhysicsConfig extends Resource

@export var max_speed: float = 900.0
@export var max_fall_speed: float = 500.0
@export var air_friction: float = 9.0
```

**Conventions:**
- `class_name` for editor registration
- `@export` for editor-editable properties
- Default values provided
- Typed properties

---

## Enum Pattern

**Source:** `scripts/utils/enums.gd`

```gdscript
class_name Enums extends Node

enum OrbType {
    RED,
    BLUE,
    HALF_SOLID
}
```

**Note:** New `OrbRarity` enum should be added here.

---

## Ball Physics Pattern

**Source:** `scripts/ball.gd`

### Current Physics Properties
```gdscript
var max_speed := 1500.0
var fall_speed := 1500.0
var air_friction := 1
```

### Half-Solid Collision
**Source:** `scripts/ball.gd:55-56`
```gdscript
elif body.is_in_group("half_solid"):
    linear_velocity = linear_velocity/3
```

### Constants Loading
**Source:** `scripts/ball.gd:59-62`
```gdscript
func load_constants():
    max_speed = Constants.ball_max_speed
    fall_speed = Constants.ball_fall_speed
    air_friction = Constants.ball_air_friction
```

---

## Score Manager Pattern

**Source:** `scripts/core/score_manager.gd`

Singleton autoload that:
- Emits `score_changed` signal on score update
- Tracks high score
- `add_score(amount: int) -> int` method
- `reset_score()` method

---

## OrbSpawner Pattern

**Source:** `scripts/orb_spawner.gd`

- Uses `OrbProps` array for weighted selection
- `spawn_zone: Rect2` for spawn area
- `max_orbs: int` limit
- Timer-based spawning at `spawn_interval`

**Selection logic (line 41-46):**
```gdscript
func _spawn_from_props() -> Node:
    if orb_props.is_empty():
        return null
    var props := orb_props[randi() % orb_props.size()]
    return create_orb_copy(props)
```

---

## Testing Pattern (GUT)

**Source:** `tests/unit/test_events.gd`, `tests/unit/test_orb_scoring.gd`

### Test Structure
```gdscript
extends GutTest

func before_each() -> void:
    # Setup

func test_something() -> void:
    assert_eq(actual, expected, "description")
```

### Key Conventions
- `extends GutTest`
- `before_each()` for setup
- `assert_eq`, `assert_true`, `assert_gt` for assertions
- Descriptive assertion messages
- Tests mirror logic from source files when testing integration

---

## Group Membership Pattern

**Source:** `scripts/ball.gd:14`, `scripts/ball.gd:50`

```gdscript
func _ready() -> void:
    add_to_group("ball")

# Usage:
if body.is_in_group("ball"):
    # ...
```

Orbs use `"orbs"` and `"orb"` groups (from design).

---

## Autoload Singleton Pattern

**Source:** `project.godot:18-26`

```
Events="*res://addons/dynamic_event_manager/src/event_manager.gd"
Constants="*res://scripts/utils/Constants.gd"
GameState="*res://scripts/core/game_state.gd"
ScoreManager="*res://scripts/core/score_manager.gd"
```

**EffectManager should follow this pattern** - new autoload for `scripts/effect_manager.gd`
