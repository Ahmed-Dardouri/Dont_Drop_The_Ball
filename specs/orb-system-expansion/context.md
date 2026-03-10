# Implementation Context - Orb System Expansion

## Summary

This document provides the implementation context for the orb system expansion. The Builder phase should reference this for integration points, constraints, and codebase conventions.

---

## Research Artifacts

| File | Purpose |
|------|---------|
| `research/existing-patterns.md` | Current codebase patterns for events, orbs, resources |
| `research/technologies.md` | Godot 4, GDScript, addons, and project structure |
| `research/broken-windows.md` | Low-risk code smells in touched files |

---

## Key Integration Points

### 1. Event System Integration
**Pattern:** Events extend `Event`, use static `invoke()`, check `PauseEvent.state`

**Files to modify:**
- None - use existing `AddScoreEvent.invoke()`, `OrbCollectedEvent.invoke()`, `SoundPlayEvent.invoke()`, `GameOverEvent.invoke()`

**New Event needed:**
- None per design - behaviors fire existing events

### 2. Ball Physics Integration
**File:** `scripts/ball.gd`

**Current:**
```gdscript
var fall_speed := 1500.0

func load_constants():
    fall_speed = Constants.ball_fall_speed
```

**Integration needed:**
- Poll `EffectManager.has_effect("slow_fall")` in `_physics_process()`
- Apply modifier to `fall_speed` based on effect value
- Preserve `base_fall_speed` for reset

### 3. Score Manager Integration
**File:** `scripts/core/score_manager.gd`

**Current:**
```gdscript
func add_score(amount: int) -> int:
    _current_score += amount
    score_changed.emit(_current_score)
```

**Integration:**
- `ScoreBehavior` calls `AddScoreEvent.invoke(score)`
- `orb_mngr.gd` handles `AddScoreEvent` and calls `ScoreManager.add_score()`
- No changes needed to ScoreManager

### 4. Game State Integration
**File:** `scripts/core/game_state.gd`

**Integration:**
- `EffectManager` should listen for `GameOverEvent` to clear effects
- Reset `Engine.time_scale = 1.0` on game over

### 5. Orb Spawner Integration
**File:** `scripts/orb_spawner.gd`

**Current:**
- Uses `OrbProps` array with random selection
- Instantiates `generic_orb_scene`

**Changes needed:**
- Replace `OrbProps` with `OrbSpawnEntry` resources
- Replace `generic_orb_scene` with new unified `orb_scene`
- Implement weighted selection with rarity tiers

---

## Critical Constraints

### Code Conventions
1. **Typed variables:** All variables must have types (`var name: Type`)
2. **Private prefix:** Internal properties use `_` prefix (`_props`, `_lifespan`)
3. **Group membership:** Use `is_in_group("ball")` not `body.name == "ball"`
4. **Event pattern:** Static `invoke()` with `PauseEvent.state` check

### Physics Constraints
1. **Ball bounce:** Must remain unchanged
2. **Half-solid behavior:** `linear_velocity = linear_velocity/3`
3. **Fall speed base:** `Constants.ball_fall_speed` (500.0)

### Score Constraints
| Orb | Score |
|-----|-------|
| Blue | 2 |
| Red | 3 |
| Half-Solid | 8 |

### Effect Duration Constraints
| Effect Type | Duration |
|-------------|----------|
| Standard (multiplier, slow_fall) | 45s |
| Time-altering (time_slow) | 10s |
| Permanent until used (double_value) | -1 |

---

## Design Concerns from Review

### 1. MovementBehavior Bounds
**Issue:** Drifter orb could drift off-screen
**Recommendation:** Add viewport bounds checking in `MovementBehavior.process()`:

```gdscript
func process(orb: Node, delta: float) -> void:
    # ... existing movement code ...

    # Clamp to viewport bounds
    var viewport = orb.get_viewport_rect()
    var margin = 50.0
    orb.global_position.x = clamp(
        orb.global_position.x,
        viewport.position.x + margin,
        viewport.position.x + viewport.size.x - margin
    )
```

### 2. Double Value Duration Constant
**Issue:** `duration=-1` for permanent effects is implicit
**Recommendation:** Define constant in EffectManager:

```gdscript
const DURATION_PERMANENT: float = -1.0
```

---

## File Migration Map

### Files to Create
| File | Purpose |
|------|---------|
| `scripts/data/orb_data.gd` | Orb property resource |
| `scripts/data/orb_spawn_entry.gd` | Spawn table entry |
| `scripts/data/behaviors/orb_behavior.gd` | Abstract behavior base |
| `scripts/data/behaviors/score_behavior.gd` | Score addition behavior |
| `scripts/data/behaviors/timed_modifier_behavior.gd` | Timed effects |
| `scripts/data/behaviors/movement_behavior.gd` | Movement behavior |
| `scripts/data/behaviors/chain_reaction_behavior.gd` | Burst behavior |
| `scripts/data/behaviors/line_clear_behavior.gd` | Line clear behavior |
| `scripts/effect_manager.gd` | Effect tracking singleton |
| `scripts/orb.gd` | Unified orb script |
| `scenes/orb.tscn` | Unified orb scene |
| `resources/orbs/*.tres` | Orb data resources |
| `resources/behaviors/*.tres` | Behavior resources |

### Files to Delete (after migration)
| File | Replacement |
|------|-------------|
| `scripts/generic_orb.gd` | `scripts/orb.gd` |
| `scripts/blue_orb.gd` | `resources/orbs/blue_orb.tres` |
| `scripts/red_orb.gd` | `resources/orbs/red_orb.tres` |
| `scripts/half_solid_orb.gd` | `resources/orbs/half_solid_orb.tres` |
| `scripts/orb_mngr.gd` | Keep (handles scoring) |
| `scripts/utils/orb_properties.gd` | `scripts/data/orb_data.gd` |
| `scenes/generic_orb.tscn` | `scenes/orb.tscn` |
| `scenes/blue_orb.tscn` | Deleted (resource-driven) |
| `scenes/red_orb.tscn` | Deleted (resource-driven) |
| `scenes/half_solid_orb.tscn` | Deleted (resource-driven) |

### Files to Modify
| File | Changes |
|------|---------|
| `scripts/orb_spawner.gd` | Use new OrbSpawnEntry, unified Orb scene |
| `scripts/ball.gd` | Poll EffectManager for slow_fall |
| `scripts/utils/enums.gd` | Add `OrbRarity` enum |
| `project.godot` | Add EffectManager autoload |

---

## Testing Requirements

### Unit Tests (GUT pattern)
- `test_orb_data.gd` - OrbData creation, defaults
- `test_orb_behaviors.gd` - Each behavior's execute()
- `test_effect_manager.gd` - Apply/remove/stack/expire
- `test_orb_spawner.gd` - Weighted selection, max limit
- `test_orb_scoring.gd` - Score with multipliers (update existing)

### Integration Tests
- `test_orb_collection_flow.gd` - Full collection flow
- `test_chain_reaction.gd` - Burst orb behavior
- `test_line_clear.gd` - Line orb behavior

### Validation
```bash
./devscripts/test.sh        # Must pass
./devscripts/smoke_test.sh  # Must pass
```

---

## Autoload Registration

Add to `project.godot` after EffectManager creation:

```ini
[autoload]
EffectManager="*res://scripts/effect_manager.gd"
```

Order matters - add after existing autoloads.

---

## Quick Reference

### Event Invocation Pattern
```gdscript
AddScoreEvent.invoke(score)
OrbCollectedEvent.invoke(orb_data)
SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
GameOverEvent.invoke()
```

### Effect Manager API (to be implemented)
```gdscript
EffectManager.apply_effect(effect_id: String, value: Variant, duration: float, source: Node = null)
EffectManager.remove_effect(effect_id: String)
EffectManager.has_effect(effect_id: String) -> bool
EffectManager.get_effect_value(effect_id: String) -> Variant
EffectManager.clear_all_effects()
```

### Ball Group Check
```gdscript
if body.is_in_group("ball"):
    # handle ball collision
```
