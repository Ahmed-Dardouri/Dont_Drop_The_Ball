# Research: Effect Manager Architecture

## Singleton Pattern

Following existing project conventions (GameState, ScoreManager), EffectManager will be an autoload.

## Core Structure

```gdscript
# effect_manager.gd (autoload: EffectManager)
extends Node

signal effect_applied(effect_id: String, value: Variant)
signal effect_removed(effect_id: String)
signal effects_changed()

# Internal state
var _active_effects: Dictionary = {}  # effect_id -> ActiveEffect

class ActiveEffect:
    var effect_id: String
    var value: Variant
    var remaining_duration: float
    var stack_count: int = 1
    var source: Node
```

## Key Methods

```gdscript
## Apply or stack an effect
func apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null) -> void:
    if _active_effects.has(effect_id):
        # Stack behavior: multiply value, refresh duration
        var existing = _active_effects[effect_id]
        existing.stack_count += 1
        existing.value = _calculate_stacked_value(existing, value)
        existing.remaining_duration = duration
    else:
        var effect = ActiveEffect.new()
        effect.effect_id = effect_id
        effect.value = value
        effect.remaining_duration = duration
        effect.source = source
        _active_effects[effect_id] = effect

    effect_applied.emit(effect_id, value)
    effects_changed.emit()

## Remove an effect
func remove_effect(effect_id: String) -> void:
    if _active_effects.erase(effect_id):
        effect_removed.emit(effect_id)
        effects_changed.emit()

## Query methods
func has_effect(effect_id: String) -> bool:
    return _active_effects.has(effect_id)

func get_effect_value(effect_id: String) -> Variant:
    if _active_effects.has(effect_id):
        return _active_effects[effect_id].value
    return null

func get_stack_count(effect_id: String) -> int:
    if _active_effects.has(effect_id):
        return _active_effects[effect_id].stack_count
    return 0
```

## Process Loop for Duration

```gdscript
func _process(delta: float) -> void:
    var expired: Array[String] = []

    for effect_id in _active_effects:
        var effect = _active_effects[effect_id]
        if effect.remaining_duration > 0:
            effect.remaining_duration -= delta
            if effect.remaining_duration <= 0:
                expired.append(effect_id)

    for effect_id in expired:
        remove_effect(effect_id)
```

## Integration with Existing Systems

### ScoreManager Integration
```gdscript
# In ScoreManager or EffectManager listener
func _on_effects_changed() -> void:
    var multiplier = 1.0
    if EffectManager.has_effect("score_multiplier"):
        multiplier = EffectManager.get_effect_value("score_multiplier")
    _current_multiplier = multiplier
```

### Ball Integration
```gdscript
# In ball.gd or BallPhysics
func apply_fall_modifier() -> void:
    var fall_modifier = 1.0
    if EffectManager.has_effect("slow_fall"):
        fall_modifier = EffectManager.get_effect_value("slow_fall")
    fall_speed = base_fall_speed * fall_modifier
```

### Time Scale Integration
```gdscript
# In EffectManager
func _on_effects_changed() -> void:
    if has_effect("time_slow"):
        Engine.time_scale = get_effect_value("time_slow")
    else:
        Engine.time_scale = 1.0
```

## Effect IDs

Standardized IDs for consistency:

| Effect ID | Value Type | Description |
|-----------|------------|-------------|
| `score_multiplier` | float | Score multiplier (2.0 = 2x) |
| `slow_fall` | float | Fall speed multiplier (0.5 = half speed) |
| `time_slow` | float | Engine.time_scale value |
| `double_value` | bool | Next orb 2x (one-time flag) |
| `combo_chain` | int | Current combo count |

## Stacking Rules

Per Q4, answer: Stack effects

```gdscript
func _calculate_stacked_value(existing: ActiveEffect, new_value: Variant) -> Variant:
    # For multipliers: multiply values
    if existing.effect_id in ["score_multiplier", "slow_fall"]:
        var result = existing.value * new_value
        # Cap slow_fall at 0.1 (90% reduction)
        if existing.effect_id == "slow_fall":
            result = max(result, 0.1)
        # Cap score_multiplier at 10x
        if existing.effect_id == "score_multiplier":
            result = min(result, 10.0)
        return result

    # For combo: increment count
    if existing.effect_id == "combo_chain":
        return existing.value + 1

    return new_value
```

## Reset on Game Over

```gdscript
func clear_all_effects() -> void:
    _active_effects.clear()
    effects_changed.emit()
```

Call from GameOverEvent handler.
