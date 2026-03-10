# Explorer Findings - Orb System Integration

> Generated: 2026-03-10
> Event: design.approved (confidence: 90%, failures_resolved: 3)

---

## Collision Detection Pattern (CRITICAL for F1 Fix)

**Source:** `scenes/blue_orb.tscn`, `scripts/blue_orb.gd`

### Current Pattern (Child Orbs)
```gdscript
# blue_orb.gd:4-5
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

# blue_orb.gd:24-26
func _on_area_2d_body_entered(body: Node2D) -> void:
    if body.name == "ball":
        orb_collected()
```

**Scene Structure:**
```
blue_orb (Node2D)
├── orb_sprite (Sprite2D)
├── Area2D
│   └── CollisionShape2D (CircleShape2D, radius=56.0)
└── Timer
```

**Signal Connection:**
```
[connection signal="body_entered" from="Area2D" to="." method="_on_area_2d_body_entered"]
```

### GenericOrb Pattern (NO Area2D)
**Source:** `scripts/generic_orb.gd:1`

```gdscript
extends Node2D
class_name GenericOrb
```

GenericOrb extends Node2D (NOT Area2D). Collision is delegated to child orbs.

**Design Fix (F1):** Add `DataOrbArea` + `CollisionShape2D` to `generic_orb.tscn`, disabled by default, enabled when OrbData path is used.

---

## Event System Pattern

**Source:** `scripts/events/orb_collected_event.gd`, `scripts/events/add_score_event.gd`

### Event Definition
```gdscript
class_name OrbCollectedEvent extends Event

var _props: OrbProps

func _init(props: OrbProps) -> void:
    _props = props

static func invoke(props: OrbProps):
    if PauseEvent.state == false:
        Events.invoke(OrbCollectedEvent.new(props))
```

### Key Conventions
- Private properties prefixed with `_`
- Static `invoke()` method
- `PauseEvent.state == false` check prevents events during pause
- No return value from `invoke()`

---

## Score Flow Pattern

**Source:** `scripts/data/behaviors/score_behavior.gd`, `scripts/core/score_manager.gd`

### ScoreBehavior.execute()
```gdscript
func execute(_context: Dictionary) -> void:
    var score: int = base_score

    # Apply double value if active
    if EffectManager.has_effect("double_value"):
        score *= 2

    # Apply score multiplier if active
    var multiplier: Variant = EffectManager.get_effect_value("score_multiplier")
    if multiplier != null:
        score = int(score * float(multiplier))

    ScoreManager.add_score(score)
```

### ScoreManager API
```gdscript
# scripts/core/score_manager.gd
func add_score(amount: int) -> int  # Returns new score
func get_score() -> int
func reset_score() -> void
signal score_changed(new_score: int)
```

---

## Effect Manager Pattern

**Source:** `scripts/effect_manager.gd`

### Caps Already Defined
```gdscript
const SCORE_MULTIPLIER_CAP: float = 10.0
const SLOW_FALL_CAP: float = 0.1
const TIME_SLOW_CAP: float = 0.25
```

### Stacking Rules
```gdscript
match effect_id:
    "score_multiplier":
        _stack_multiplicative_ceiling(...)  # 2x + 2x = 4x, capped at 10x
    "slow_fall":
        _stack_multiplicative_floor(...)    # Capped at 0.1
    "time_slow":
        _stack_multiplicative_floor(...)    # Capped at 0.25x
    "combo_chain":
        _stack_increment(...)               # 1 + 1 = 2
    "double_value":
        # Single instance, no stacking
```

---

## Test Pattern (GUT)

**Source:** `tests/unit/test_effect_manager.gd`, `tests/unit/test_score_behavior.gd`

### Test Structure
```gdscript
extends GutTest

func before_each():
    EffectManager.clear_all_effects()

func test_something():
    # Given: setup
    EffectManager.apply_effect("test", 1.0, 10.0)

    # When: action
    var value = EffectManager.get_effect_value("test")

    # Then: assertion
    assert_eq(value, 1.0, "Description")
```

### Key Assertions
- `assert_eq(actual, expected, "message")`
- `assert_true(condition, "message")`
- `assert_false(condition, "message")`
- `assert_null(value, "message")`
- `await wait_seconds(0.2)` for async tests

---

## Orb Group Membership

**Source:** `scripts/orb_spawner.gd:24`

```gdscript
get_tree().get_nodes_in_group("orbs").size()
```

New OrbData orbs MUST be added to "orbs" group for:
1. Spawn limit checking
2. BurstBehavior radius detection
3. LineClearBehavior line detection

**Implementation:**
```gdscript
func _ready() -> void:
    add_to_group("orbs")
```

---

## Ball Detection Pattern

**Source:** `scripts/blue_orb.gd:25`

```gdscript
if body.name == "ball":
    orb_collected()
```

**Issue:** Hardcoded name check. Should use group check:
```gdscript
if body.is_in_group("ball"):
    orb_collected()
```

---

## Available Assets

**Source:** `sprites/` directory

| Asset | Path | Usage |
|-------|------|-------|
| blue_ball.png | `sprites/blue_ball.png` | Blue orb texture |
| red_ball.png | `sprites/red_ball.png` | Red orb texture |
| collect_half.png | `sprites/collect_half.png` | Half-solid collect area |
| solid_half.png | `sprites/solid_half.png` | Half-solid physics body |
| acorn.png | `sprites/acorn.png` | Acorn texture |

### Placeholder Strategy for New Orbs
Per design constraints: "No large asset work"

Options:
1. Reuse existing textures with `modulate` color
2. Use `ImageTexture` created from code (colored circles)
3. Share textures between similar orb types

---

## Scene Structure for GenericOrb

**Source:** `scenes/generic_orb.tscn`

```
generic_orb (Node2D) - scale = Vector2(0.61, 0.61)
├── Timer (wait_time=2.0, one_shot=true)
└── child_orbs (Node2D)
    ├── blue_orb (BlueOrb scene)
    ├── red_orb (RedOrb scene)
    └── half_solid_orb (HalfSolidOrb scene)
```

**Design Addition (F1 Fix):**
```
+ DataOrbArea (Area2D) - disabled by default
+   CollisionShape2D (CircleShape2D) - radius from OrbData.collision_radius
```

---

## Enums Available

**Source:** `scripts/utils/enums.gd`

```gdscript
enum OrbType { RED, BLUE, HALF_SOLID }
enum OrbRarity { COMMON, UNCOMMON, RARE }
```

**Note:** `OrbRarity` already exists! No need to add it.
