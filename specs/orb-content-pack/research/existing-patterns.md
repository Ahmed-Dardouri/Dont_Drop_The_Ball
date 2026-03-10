# Existing Patterns - Orb Content Pack

## OrbBehavior System

**File:** `scripts/data/behaviors/orb_behavior.gd:1-33`

Abstract Resource class with virtual methods:

```gdscript
class_name OrbBehavior extends Resource

@export var behavior_id: String = ""

func execute(_context: Dictionary) -> void:
    pass

func process(_orb: Node, _delta: float) -> void:
    pass

func on_spawn(_orb: Node, _progress: float) -> void:
    pass
```

**Context Dictionary Structure:**
- `orb`: Node - The orb being collected
- `orb_data`: OrbData - Data resource for the orb
- `collector`: Node - Node that collected the orb (typically ball)

---

## OrbData Resource

**File:** `scripts/data/orb_data.gd:1-57`

Properties:
- `display_name: String = "Orb"`
- `texture: Texture2D`
- `scale: Vector2 = Vector2.ONE`
- `base_score: int = 1`
- `lifespan: float = 30.0`
- `rarity: Enums.OrbRarity = COMMON`
- `collision_radius: float = 32.0`
- `is_half_solid: bool = false`
- `behaviors: Array[OrbBehavior] = []`
- `spawn_animation_duration: float = 1.5`

---

## EffectManager Singleton

**File:** `scripts/effect_manager.gd:1-164`

Registered as autoload `EffectManager`.

### Key Methods

```gdscript
func apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null) -> void
func remove_effect(effect_id: String) -> void
func has_effect(effect_id: String) -> bool
func get_effect_value(effect_id: String) -> Variant
func clear_all_effects() -> void
```

### Stacking Rules (effect_manager.gd:69-86)

| Effect ID | Stacking | Cap | Notes |
|-----------|----------|-----|-------|
| `score_multiplier` | Multiplicative ceiling | 10.0 | Values multiplied, capped at 10x |
| `slow_fall` | Multiplicative floor | 0.1 | Values multiplied, floored at 0.1 |
| `time_slow` | Multiplicative floor | 0.25 | Sets `Engine.time_scale` |
| `combo_chain` | Increment | None | Values added together |
| `double_value` | Single instance | N/A | No stacking, first only |
| Default | Replace | N/A | New effect replaces old |

### Constants

```gdscript
const DURATION_PERMANENT: float = -1.0
const SCORE_MULTIPLIER_CAP: float = 10.0
const SLOW_FALL_CAP: float = 0.1
const TIME_SLOW_CAP: float = 0.25
```

---

## Ball Collision Handling

**File:** `scripts/ball.gd:49-56`

Current `_on_body_entered` implementation:

```gdscript
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("ground") && !game_over:
        game_over = true
        GameOverEvent.invoke()
        PauseEvent.invoke(true)
        SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.GAME_OVER)
    elif body.is_in_group("half_solid"):
        linear_velocity = linear_velocity/3
```

**Integration Point:** Add sticky_head effect check for player collision.

---

## Player (physics_player.gd)

**File:** `scripts/physics_player.gd:1-237`

- Extends `RigidBody2D`
- **NOT currently in "player" group** - needs `add_to_group("player")` in `_ready()`
- Has ground_cast and ceiling_cast ShapeCast2D nodes
- Handles jump, gravity, horizontal movement

**CRITICAL:** Player must be added to "player" group for sticky head detection.

---

## ScoreManager Singleton

**File:** `scripts/core/score_manager.gd:1-51`

```gdscript
signal score_changed(new_score: int)
signal high_score_changed(new_high: int)

func get_score() -> int
func get_high_score() -> int
func add_score(amount: int) -> int
func reset_score() -> void
func set_high_score(value: int) -> void
```

---

## Current Orb Collection Flow

**File:** `scripts/blue_orb.gd:18-26`

```gdscript
func orb_collected():
    OrbCollectedEvent.invoke(_props)
    SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
    queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```

**File:** `scripts/orb_mngr.gd:13-34`

Handles `OrbCollectedEvent` and adds score via `AddScoreEvent.invoke()`.

---

## Enums

**File:** `scripts/utils/enums.gd:66-70`

```gdscript
enum OrbRarity {
    COMMON,
    UNCOMMON,
    RARE
}
```

---

## Event System

Uses `dynamic_event_manager` addon.

Pattern for creating events:
- Event classes in `scripts/events/`
- Invoke with `EventClass.invoke(args)`
- Listen with `Events.add_listener(EventClass, handler)`

---

## Testing Patterns (GUT)

**File:** `tests/unit/test_effect_manager.gd`

```gdscript
extends GutTest

func before_each():
    EffectManager.clear_all_effects()

func test_example():
    assert_eq(actual, expected, "message")
    assert_true(condition, "message")
    assert_null(value, "message")
    await wait_seconds(0.2)
```

---

## Spawner System

**File:** `scripts/orb_spawner.gd:1-53`

Current spawner uses `OrbProps` (old system with just `Type: Enums.OrbType`):
- Spawns `GenericOrb` scene
- Uses `get_tree().get_nodes_in_group("orbs")` for count
- Random selection from `orb_props` array

**Note:** Design document references data-driven OrbData system but current spawner uses OrbProps.
