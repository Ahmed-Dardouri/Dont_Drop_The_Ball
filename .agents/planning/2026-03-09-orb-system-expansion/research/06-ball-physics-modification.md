# Research: Ball Physics External Modification

## Current Ball Physics

From `ball.gd`:

```gdscript
extends RigidBody2D

var max_speed := 1500.0
var fall_speed := 1500.0
var air_friction := 1

func clamp_fall_speed():
    if fall_speed > 0.0:
        var v := linear_velocity.y
        if v > fall_speed:
            linear_velocity.y = fall_speed
```

## External Modification Pattern

The EffectManager needs to modify ball physics without tight coupling.

### Option 1: Ball Polls EffectManager (Recommended)

Ball queries EffectManager each frame:

```gdscript
# In ball.gd
var base_fall_speed := 1500.0

func _physics_process(delta: float) -> void:
    _apply_effect_modifiers()
    clamp_max_speed()
    clamp_fall_speed()
    apply_air_friction()

func _apply_effect_modifiers() -> void:
    var fall_modifier := 1.0

    if EffectManager.has_effect("slow_fall"):
        fall_modifier = EffectManager.get_effect_value("slow_fall")

    fall_speed = base_fall_speed * fall_modifier
```

**Pros:**
- Loose coupling (ball knows about EffectManager, not vice versa)
- Simple to understand
- Ball is in control of its own physics

**Cons:**
- Polling every frame (minimal cost)

### Option 2: EffectManager Pushes to Ball

EffectManager finds ball and modifies it:

```gdscript
# In effect_manager.gd
func _on_slow_fall_changed(value: float) -> void:
    var ball = get_tree().get_first_node_in_group("ball")
    if ball:
        ball.fall_speed = ball.base_fall_speed * value
```

**Pros:**
- No polling

**Cons:**
- Tight coupling (EffectManager knows about ball)
- Need to handle ball destruction/recreation
- More complex state management

### Option 3: Signal-Based

EffectManager emits signal, ball subscribes:

```gdscript
# In effect_manager.gd
signal slow_fall_changed(multiplier: float)

# In ball.gd
func _ready() -> void:
    EffectManager.slow_fall_changed.connect(_on_slow_fall_changed)

func _on_slow_fall_changed(multiplier: float) -> void:
    fall_speed = base_fall_speed * multiplier
```

**Recommendation:** Use Option 1 (Polling) for simplicity. The performance cost is negligible for a single ball.

## Slow Fall Effect Details

| Property | Value |
|----------|-------|
| Base fall_speed | 1500.0 (from Constants) |
| Effect ID | `slow_fall` |
| Base value | 0.5 (50% speed) |
| Stack behavior | Multiply (0.5, 0.25, cap at 0.1) |
| Duration | 45 seconds |

### Stacking Math

```gdscript
# 1 orb: fall_speed = 1500 * 0.5 = 750
# 2 orbs: fall_speed = 1500 * 0.25 = 375
# 3 orbs: fall_speed = 1500 * 0.125 = 187.5 (capped at 0.1 = 150)
```

## Integration Points

### 1. Ball Setup

```gdscript
# In ball.gd
func load_constants():
    max_speed = Constants.ball_max_speed
    base_fall_speed = Constants.ball_fall_speed  # Store base
    fall_speed = base_fall_speed  # Current (modified)
    air_friction = Constants.ball_air_friction
```

### 2. Effect Application

```gdscript
# In ball.gd _physics_process or dedicated method
func _apply_active_effects() -> void:
    # Slow Fall
    if EffectManager.has_effect("slow_fall"):
        var modifier = EffectManager.get_effect_value("slow_fall")
        fall_speed = base_fall_speed * modifier
    else:
        fall_speed = base_fall_speed
```

### 3. Effect Cleanup (Game Over)

```gdscript
# When game over or scene change
func _on_game_over() -> void:
    fall_speed = base_fall_speed  # Reset to normal
```

## Summary

| Aspect | Decision |
|--------|----------|
| Pattern | Ball polls EffectManager |
| Effect ID | `slow_fall` |
| Base value | 0.5 (50% of normal) |
| Stacking | Multiply, cap at 0.1 |
| Duration | 45 seconds |
| Integration | `_apply_active_effects()` in `_physics_process` |
