# Orb System Expansion - Requirements (Bridge Integration)

## Overview

Integrate the new data-driven orb system into actual gameplay by bridging the existing `GenericOrb` system to support `OrbData` alongside `OrbProps`. This enables new orb types to spawn and function without a large refactor.

---

## Consolidated Requirements (from Q&A)

### REQ-1: Architecture - Bridge Pattern (Revised)

**Source:** Q2 (Bridge Approach Decision)

The system shall use a bridge pattern to connect the new OrbData system to the existing GenericOrb pipeline:

- GenericOrb accepts EITHER OrbProps (old) OR OrbData (new)
- Existing BlueOrb/RedOrb/HalfSolidOrb child scenes continue working unchanged
- New orb types use the OrbData path with behavior execution
- OrbAdapter utility converts OrbData for spawner compatibility

**Key Components:**
- `OrbData` (Resource) - already exists, defines all orb properties
- `OrbBehavior` (Abstract Resource) - already exists, pluggable behaviors
- `OrbAdapter` (NEW) - bridges OrbData to existing spawn system
- `GenericOrb` (UPDATED) - adds OrbData behavior execution path

---

### REQ-2: Effect Application Model - Singleton Effect Manager

**Source:** Q2 (Original)

The system shall use a central `EffectManager` autoload for effect tracking:

- Tracks all active effects with stack/refresh/expiration rules
- Single source of truth for "what effects are active"
- Queryable from any system (UI, player, ball, scoring)
- Supports complex conflict resolution
- Testable in isolation

**Status:** ✅ COMPLETED - `scripts/effect_manager.gd`

---

### REQ-3: Orb Types - 8 New Types

**Source:** Objective + Q3

The integration shall enable these new orb types:

| # | Orb Name | Effect Type | Behaviors Needed |
|---|----------|-------------|------------------|
| 1 | Burst Orb | Instant/Chain | BurstBehavior (radius collection) |
| 2 | Vertical Line Orb | Instant/Area | LineClearBehavior (VERTICAL) |
| 3 | Horizontal Line Orb | Instant/Area | LineClearBehavior (HORIZONTAL) |
| 4 | Slow Fall Orb | Timed | TimedModifierBehavior (slow_fall) |
| 5 | Sticky Head Orb | Timed | TimedModifierBehavior (sticky_head) |
| 6 | Double Value Orb | Timed | TimedModifierBehavior (double_value) |
| 7 | Combo Starter Orb | Timed/Stack | ComboStarterBehavior |
| 8 | Drifter Orb | Movement | MovementBehavior (oscillate) |

**Existing behaviors to reuse:**
- `ScoreBehavior` ✅
- `TimedModifierBehavior` ✅

**New behaviors to implement:**
- `BurstBehavior` (chain reaction)
- `LineClearBehavior` (vertical/horizontal)
- `MovementBehavior` (drifter movement)
- `ComboStarterBehavior` (combo window)

---

### REQ-4: Effect Stacking & Duration Rules

**Source:** Q4 (Original)

Effects shall stack with refreshed duration:

| Effect | Duration | Stack Behavior |
|--------|----------|----------------|
| Score Multiplier | 45s | Stack (2x + 2x = 4x), cap 10x |
| Slow Fall | 45s | Stack, cap 90% reduction |
| Time Slow | 10s | Stack, cap 0.25x speed |
| Combo Chain | 10s | Refresh timer, increment count |
| Double Value | Until used | Single instance |

---

### REQ-5: Spawn System - Bridge Integration

**Source:** Q5 + Bridge Approach

The spawn system shall support both old and new orb sources:

**OrbSpawner Changes:**
- Add `@export var orb_data_array: Array[OrbData] = []`
- Combine orb_props[] + orb_data_array[] for spawn selection
- Weight selection by rarity tier
- Use OrbAdapter for OrbData orbs

**Rarity Distribution:**
| Rarity | Weight | Spawn Rate |
|--------|--------|------------|
| COMMON | 100 | ~50% |
| UNCOMMON | 40 | ~30% |
| RARE | 10 | ~10% |

---

### REQ-6: Migration Strategy - Bridge (Revised)

**Source:** Q2 (Bridge Decision)

Integration shall use a bridge pattern, not a big-bang refactor:

1. Create OrbAdapter utility class
2. Modify GenericOrb to accept and execute OrbData behaviors
3. Update OrbSpawner to support OrbData array
4. Create new behavior classes as needed
5. Create orb resource files (.tres) for new orb types
6. Add debug spawn mechanism for testing

**Files to Create:**
- `scripts/utils/orb_adapter.gd` - NEW adapter (~30 lines)
- `scripts/data/behaviors/burst_behavior.gd` - NEW
- `scripts/data/behaviors/line_clear_behavior.gd` - NEW
- `scripts/data/behaviors/movement_behavior.gd` - NEW
- `scripts/data/behaviors/combo_starter_behavior.gd` - NEW
- `resources/orbs/*.tres` - NEW orb definitions

**Files to Modify:**
- `scripts/generic_orb.gd` - Add OrbData support (~15 lines)
- `scripts/orb_spawner.gd` - Add OrbData array support (~20 lines)

**Files Unchanged:**
- `scripts/blue_orb.gd`, `red_orb.gd`, `half_solid_orb.gd` - preserved
- `scripts/utils/orb_properties.gd` - preserved
- All existing orb scenes - preserved

---

### REQ-7: Line Orb Scoring - Full Points

**Source:** Q7 (Original)

When Vertical/Horizontal Line orbs collect other orbs, each collected orb shall award its full point value.

---

### REQ-8: Debug Spawn Mechanism

**Source:** Objective

A debug spawn mechanism shall enable reliable manual testing:

- Add `@export var debug_force_orb_type: String = ""` to OrbSpawner
- When non-empty, only spawn orbs matching that display_name
- Editor-only toggle, safe for production builds
- Document exact steps for manual verification

---

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-1 | All orb logic must be unit-testable |
| NFR-2 | New orb types require Resource files + behaviors only |
| NFR-3 | Effect stacking must be deterministic and documented |
| NFR-4 | Bridge preserves existing gameplay feel |
| NFR-5 | All changes validated via `./devscripts/test.sh` |
| NFR-6 | Typed GDScript throughout |

---

## Constraints

- Godot 4.4.1, GDScript, typed
- Keep diffs small and focused (~4 file changes for core bridge)
- No large asset work (use existing textures)
- Preserve ball bounce mechanic unchanged
- 45 second effect duration (10s for time-altering effects)
- Old OrbProps system must continue working

---

## Success Criteria

- [ ] Bridge connects OrbData to GenericOrb spawn pipeline
- [ ] 8 new orb types implemented with behavior classes
- [ ] Orb resource files (.tres) exist for all new orbs
- [ ] OrbSpawner produces both old and new orb types
- [ ] GenericOrb executes OrbData behaviors on collection
- [ ] Debug spawn mechanism enables manual testing
- [ ] All tests pass (`./devscripts/test.sh` exits 0)
- [ ] Existing gameplay is not unintentionally broken
