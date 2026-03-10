# Research: Time Scale Implementation

## Godot 4 Engine.time_scale

Godot provides a global time scale via the `Engine` singleton:

```gdscript
# Slow motion (50% speed)
Engine.time_scale = 0.5

# Normal speed
Engine.time_scale = 1.0

# Fast motion (200% speed)
Engine.time_scale = 2.0
```

## What Engine.time_scale Affects

| Affected | Not Affected |
|---------|--------------|
| `_process(delta)` | `_physics_process(delta)` (delta is adjusted) |
| `_physics_process(delta)` | Input handling |
| Timer nodes | Real-world time |
| Tween durations | UI animations (usually) |
| AnimationPlayer | Sound playback |

**Important:** `delta` in `_process` and `_physics_process` is automatically adjusted by `Engine.time_scale`.

## Implementation for Time Slow Orb

### EffectManager Integration

```gdscript
# In effect_manager.gd

signal time_scale_changed(new_scale: float)

func _update_time_scale() -> void:
    if has_effect("time_slow"):
        var scale = get_effect_value("time_slow")
        Engine.time_scale = scale
        time_scale_changed.emit(scale)
    else:
        Engine.time_scale = 1.0
        time_scale_changed.emit(1.0)

func apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null) -> void:
    # ... existing code ...
    if effect_id == "time_slow":
        _update_time_scale()

func remove_effect(effect_id: String) -> void:
    # ... existing code ...
    if effect_id == "time_slow":
        _update_time_scale()
```

### Stacking Time Slow

Based on Q4 answer (stack behavior):

```gdscript
# Base: 0.5 (50% speed)
# 2 stacks: 0.5 * 0.5 = 0.25 (25% speed)
# 3 stacks: 0.5 * 0.5 * 0.5 = 0.125 (capped at 0.25)

func _calculate_stacked_value(existing: ActiveEffect, new_value: Variant) -> Variant:
    if existing.effect_id == "time_slow":
        var result = existing.value * new_value
        return max(result, 0.25)  # Don't go below 0.25x speed
    # ... other effects
```

## Visual Feedback for Slow Motion

### Option 1: Engine.time_scale (Simple)

Everything slows automatically - no extra code needed for visuals.

**Pros:** Simple, consistent
**Cons:** UI feels sluggish, sound slows down

### Option 2: Selective Slow Motion

Only slow game logic, keep UI normal:

```gdscript
# In player/ball scripts, apply time scale manually
func _physics_process(delta: float) -> void:
    var adjusted_delta = delta
    if EffectManager.has_effect("time_slow"):
        # Physics delta is already scaled, so we use it directly
        pass

    # UI elements use _process and can check for pause
```

### Option 3: Post-Processing Effect

Add visual slow-motion effect via shader:

```gdscript
# On CanvasLayer with ColorRect + Shader
func _on_time_scale_changed(new_scale: float) -> void:
    if new_scale < 1.0:
        $ColorRect.material.set_shader_parameter("blur_amount", (1.0 - new_scale) * 0.5)
    else:
        $ColorRect.material.set_shader_parameter("blur_amount", 0.0)
```

**Recommendation:** Start with Option 1 (Engine.time_scale). It's simplest and works well for a relaxed game. Add visual polish later.

## Sound Considerations

Audio pitch can be adjusted to match time scale:

```gdscript
# In sound manager
func _on_time_scale_changed(new_scale: float) -> void:
    for player in active_audio_players:
        if player.stream is AudioStreamWAV or AudioStreamOggVorbis:
            player.pitch_scale = new_scale
```

**Or keep sound normal** for more dramatic effect (sound continues at normal pace while game slows).

## Duration for Time Slow

Per Q4: 10 seconds (more impactful, doesn't overstay welcome)

## Reset on Game Over

```gdscript
# In effect_manager.gd or game_over handler
func _on_game_over() -> void:
    Engine.time_scale = 1.0  # Always reset to normal
    clear_all_effects()
```

## Summary

| Aspect | Decision |
|--------|----------|
| Implementation | `Engine.time_scale` via EffectManager |
| Stacking | Multiply (0.5 * 0.5 = 0.25), cap at 0.25 |
| Duration | 10 seconds |
| Visual | Rely on Engine.time_scale (simple) |
| Sound | Keep normal pitch for contrast (optional: can add later) |
| Reset | On game over, always reset to 1.0 |
