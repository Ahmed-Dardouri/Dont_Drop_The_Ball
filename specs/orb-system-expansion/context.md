# Implementation Context - Orb System Expansion

> **Approach:** Bridge Pattern (preserve old, add new)
> **Design Confidence:** 95%
> **Generated:** 2026-03-10 (Explorer Phase - Post Design Approval)
> **Status:** F1/F2 fixes VERIFIED COMPLETE, awaiting OrbAdapter + Spawner integration

## Summary

This document provides the implementation context for the orb system bridge integration. The Builder phase should reference this for integration points, constraints, and codebase conventions.

**Key Insight:** The design uses a BRIDGE pattern - preserving the existing OrbProps path while adding OrbData support. Do NOT delete existing orb files.

---

## ⚠️ VERIFIED IMPLEMENTATION STATE (2026-03-10)

### ✅ Already Implemented
| Component | Status | Evidence |
|-----------|--------|----------|
| GenericOrb F1 (Collision) | DONE | `scenes/generic_orb.tscn:12-15` has DataOrbArea + CollisionShape2D |
| GenericOrb F2 (Process Loop) | DONE | `scripts/generic_orb.gd:42-56` has `_process()` with behavior.process() |
| GenericOrb.set_orb_data() | DONE | `scripts/generic_orb.gd:62-91` |
| GenericOrb.on_orb_collected() | DONE | `scripts/generic_orb.gd:158-168` executes behaviors |
| OrbData Resource | DONE | `scripts/data/orb_data.gd` |
| OrbBehavior Base | DONE | `scripts/data/behaviors/orb_behavior.gd` |
| ScoreBehavior | DONE | `scripts/data/behaviors/score_behavior.gd` |
| TimedModifierBehavior | DONE | `scripts/data/behaviors/timed_modifier_behavior.gd` |
| EffectManager | DONE | `scripts/effect_manager.gd` (autoload singleton) |
| ScoreManager | DONE | `scripts/core/score_manager.gd` (autoload singleton) |
| Unit Tests for F1/F2 | DONE | `tests/unit/test_generic_orb_collision.gd`, `test_generic_orb_process_loop.gd` |

### ❌ Blocking Runtime Integration (Builder Must Implement)
| Component | Status | File to Create/Modify |
|-----------|--------|----------------------|
| OrbAdapter utility | MISSING | `scripts/utils/orb_adapter.gd` (NEW) |
| OrbSpawner.orb_data_array | MISSING | `scripts/orb_spawner.gd` (MODIFY) |
| OrbSpawner.debug_force_orb_type | MISSING | `scripts/orb_spawner.gd` (MODIFY) |
| Test orb resource | MISSING | `resources/orbs/test_orb.tres` (NEW) |

---

## Research Artifacts

| File | Purpose |
|------|---------|
| `research/existing-patterns.md` | Current codebase patterns for events, orbs, resources |
| `research/explorer-findings.md` | Explorer research on collision patterns, integration points |
| `research/technologies.md` | Godot 4, GDScript, addons, and project structure |
| `research/broken-windows.md` | Low-risk code smells in touched files |

---

## Bridge Architecture

```
OrbSpawner
├── orb_props: Array[OrbProps] → GenericOrb → BlueOrb/RedOrb/HalfSolidOrb (UNCHANGED)
└── orb_data_array: Array[OrbData] → OrbAdapter → GenericOrb → execute behaviors (NEW)
```

**Key Principle:** Old path remains UNCHANGED. New path adds capability without breaking existing orbs.

---

## ~~Critical Fixes (from Design Critic)~~ → VERIFIED COMPLETE

### F1: Collision Detection (BLOCKING - MUST FIX FIRST)

**Problem:** GenericOrb has NO Area2D. OrbData orbs would have no collision.

**Solution:** Add `DataOrbArea` + `CollisionShape2D` to `scenes/generic_orb.tscn`

```gdscript
# Add to generic_orb.gd
@onready var data_orb_area: Area2D = $DataOrbArea
@onready var data_orb_collision: CollisionShape2D = $DataOrbArea/CollisionShape2D
var _orb_data: OrbData = null
var _visual_sprite: Sprite2D = null

func set_orb_data(orb_data: OrbData) -> void:
    _orb_data = orb_data
    # Free child orbs - OrbData path doesn't need them
    for child in child_orbs.get_children():
        child.queue_free()
    # Create visual sprite
    _visual_sprite = Sprite2D.new()
    _visual_sprite.texture = orb_data.texture
    _visual_sprite.modulate = Color(1, 1, 1, 0)  # Start invisible
    add_child(_visual_sprite)
    # Configure collision
    var shape := CircleShape2D.new()
    shape.radius = orb_data.collision_radius
    data_orb_collision.shape = shape
    data_orb_area.monitoring = true
    # Connect signal
    if not data_orb_area.body_entered.is_connected(_on_data_orb_area_body_entered):
        data_orb_area.body_entered.connect(_on_data_orb_area_body_entered)

func _on_data_orb_area_body_entered(body: Node2D) -> void:
    if _orb_data == null:
        return
    if body.is_in_group("ball"):
        on_orb_collected()
```

### F2: Behavior Process Loop

**Solution:** Add behavior.process() loop in GenericOrb._process()

```gdscript
func _process(delta: float) -> void:
    # Existing spawn animation
    if timer.time_left != 0:
        set_child_opacity_to_timer()
        if _visual_sprite != null:
            _visual_sprite.modulate.a = 1.0 - (timer.time_left / timer.wait_time)
        return

    # Process behaviors for OrbData orbs
    if _orb_data != null:
        for behavior: OrbBehavior in _orb_data.behaviors:
            behavior.process(self, delta)
```

### F3: Chain Collection Protocol

**Solution:** Add static `collect_orb()` helper to OrbBehavior base class

```gdscript
# Add to scripts/data/behaviors/orb_behavior.gd
static func collect_orb(target: Node, score_multiplier: float = 1.0) -> int:
    var score_value: int = 0
    # Try OrbData path
    if target.has_method("get_orb_data"):
        var orb_data: OrbData = target.get_orb_data()
        if orb_data != null:
            score_value = int(orb_data.base_score * score_multiplier)
    # Fallback to OrbProps path
    if score_value == 0 and target.has_method("get_orb_props"):
        var props = target.get_orb_props()
        if props != null:
            match props.Type:
                Enums.OrbType.BLUE: score_value = 10
                Enums.OrbType.RED: score_value = 25
                _: score_value = 10
    SoundPlayEvent.invoke(Enums.SoundType.SFX, Enums.Sounds.ORB_COLLECTED)
    target.queue_free()
    return score_value
```

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
