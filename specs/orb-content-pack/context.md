# Implementation Context - Orb Content Pack

## Summary

Research complete for implementing 8 new orb types using the existing OrbBehavior/EffectManager systems. The codebase has a solid foundation with:
- Abstract `OrbBehavior` class for defining behaviors
- `OrbData` resource for data-driven orb definitions
- `EffectManager` singleton with stacking rules for timed effects
- GUT testing framework with established patterns

---

## Integration Points

### 1. Ball Collision (Sticky Head)

**File:** `scripts/ball.gd:49-56`

Current `_on_body_entered` handles:
- Ground collision → game over
- Half-solid collision → velocity/3

**Required Change:** Add player collision detection for sticky_head effect

```gdscript
func _on_body_entered(body: Node) -> void:
    # ... existing code ...

    # NEW: Apply sticky head dampening on player collision
    if body.is_in_group("player") and EffectManager.has_effect("sticky_head"):
        var damping: float = EffectManager.get_effect_value("sticky_head")
        linear_velocity.y *= damping  # e.g., 0.5 = 50% slower bounce
```

**Dependency:** Player must be in "player" group (see below)

---

### 2. Player Group Membership (CRITICAL)

**File:** `scripts/physics_player.gd:53`

**Required Change:** Add player to "player" group in `_ready()`

```gdscript
func _ready() -> void:
    add_to_group("player")  # ADD THIS LINE
    load_constants()
    # ... rest of _ready
```

**Impact:** Without this, sticky head collision detection will fail.

---

### 3. EffectManager - New Effect Type

**File:** `scripts/effect_manager.gd:69-86`

The `apply_effect` function has a default case that handles unknown effects:

```gdscript
_:
    # Default: replace existing effect
    _active_effects[effect_id] = ActiveEffect.new(effect_id, value, duration, source)
```

**Good News:** The `sticky_head` effect will work with default (replace) stacking. No EffectManager changes needed.

---

### 4. Behavior Classes Location

**Directory:** `scripts/data/behaviors/`

Existing:
- `orb_behavior.gd` - Base class

To create:
- `score_behavior.gd`
- `timed_modifier_behavior.gd`
- `chain_reaction_behavior.gd`
- `line_clear_behavior.gd`
- `movement_behavior.gd`
- `sticky_head_behavior.gd`

---

### 5. OrbData Resources Location

**Directory:** `resources/orbs/` (to be created)

Each orb type as `.tres` file referencing behavior resources.

---

## Constraints

### Technical Constraints

1. **No architecture refactoring** - Use existing systems as-is
2. **Player group missing** - Must add `add_to_group("player")` to physics_player.gd
3. **Spawner uses old OrbProps** - May need integration work or parallel system
4. **Ball collision via body_entered** - Sticky head must integrate here, not in physics_process

### Design Constraints

1. **Sticky head is collision-based** - Apply damping ONLY on player collision, NOT every frame
2. **Effect stacking** - Use existing EffectManager stacking rules
3. **Test validation** - All tests must pass via `./devscripts/test.sh`

---

## Implementation Sequence

Based on design.md Section 7:

### Phase 1: Core Behaviors
1. `ScoreBehavior` - Base scoring with multiplier/double value support
2. `TimedModifierBehavior` - Generic effect application

### Phase 2: Area Effects
3. `ChainReactionBehavior` - Burst orb radius clear
4. `LineClearBehavior` - Vertical/horizontal line clear

### Phase 3: Movement & New Effect
5. `MovementBehavior` - Drifter orb sine wave movement
6. `StickyHeadBehavior` - Effect application
7. Update ball.gd for sticky_head collision check
8. Update physics_player.gd to add "player" group

### Phase 4: Orb Data Resources
9. Create 8 .tres files for orb definitions
10. Integrate with spawning system

### Phase 5: Testing
11. Unit tests for each behavior
12. Run `./devscripts/test.sh` validation

---

## Files to Create

```
scripts/data/behaviors/
├── score_behavior.gd
├── timed_modifier_behavior.gd
├── chain_reaction_behavior.gd
├── line_clear_behavior.gd
├── movement_behavior.gd
└── sticky_head_behavior.gd

resources/orbs/
├── burst_orb.tres
├── vertical_line_orb.tres
├── horizontal_line_orb.tres
├── slow_fall_orb.tres
├── sticky_head_orb.tres
├── double_value_orb.tres
├── combo_starter_orb.tres
└── drifter_orb.tres

tests/unit/
├── test_score_behavior.gd
├── test_chain_reaction_behavior.gd
├── test_line_clear_behavior.gd
├── test_movement_behavior.gd
└── test_sticky_head_behavior.gd
```

## Files to Modify

```
scripts/ball.gd              # Add sticky_head effect handling
scripts/physics_player.gd    # Add to "player" group
scripts/orb_spawner.gd       # Integrate new orb types (if needed)
```

---

## Verification Checklist

- [ ] `./devscripts/test.sh` exits 0
- [ ] All 8 orb types spawnable in-game
- [ ] Sticky head reduces bounce velocity on player collision
- [ ] Burst orb clears nearby orbs
- [ ] Line orbs clear aligned orbs
- [ ] Drifter orb moves horizontally
- [ ] Existing effects (slow_fall, double_value, combo_chain) work with new orbs

---

## Open Questions for Builder

1. **Spawner Integration:** Should new orbs use existing OrbProps system or migrate to OrbData?
   - Current spawner uses OrbProps (just type enum)
   - Design assumes OrbData-driven system
   - Recommendation: Create parallel integration or extend spawner

2. **Orb Scene:** Does the game have a generic orb scene that uses OrbData?
   - Current GenericOrb uses OrbProps
   - May need new scene or modification

3. **Texture Resources:** Where are orb textures stored?
   - Check `sprites/` directory for existing textures
   - May need placeholder textures for new orbs
