# Orb System Expansion - Requirements

## Overview

Expand the orb system in "Don't Drop the Ball" from 3 hardcoded orb types to a modular, data-driven system supporting 12+ orb types with effects, stacking, and varied behaviors.

---

## Consolidated Requirements (from Q&A)

### REQ-1: Architecture - Unified Orb Scene + Data-Driven Config

**Source:** Q1

The system shall use a single unified Orb scene with data-driven configuration:

- One Orb scene with configurable behavior components
- All orb properties (sprite, score, effects, lifespan) defined in Resource files
- New orb types = new Resource definitions, no new scripts unless truly unique behavior
- Eliminate code duplication across existing BlueOrb, RedOrb, HalfSolidOrb

**Key Components:**
- `OrbData` (Resource) - defines all orb properties
- `OrbBehavior` (Abstract Resource) - pluggable behaviors
- `Orb` (Scene + Script) - single unified orb scene

---

### REQ-2: Effect Application Model - Singleton Effect Manager

**Source:** Q2

The system shall use a central `EffectManager` autoload for effect tracking:

- Tracks all active effects with stack/refresh/expiration rules
- Single source of truth for "what effects are active"
- Queryable from any system (UI, player, ball, scoring)
- Supports complex conflict resolution
- Testable in isolation

**Key Structure:**
- `EffectManager` (Autoload) - central effect tracking
- `ActiveEffect` - runtime effect state with duration, stack count, source

---

### REQ-3: First Orb Pack - 9 New Orb Types

**Source:** Q3

The first content pack shall include 9 new orb types:

| # | Orb Name | Effect Type | Complexity |
|---|----------|-------------|------------|
| 1 | Score Multiplier | Timed/Stack | Low |
| 2 | Slow Fall | Timed | Low-Med |
| 3 | Burst | Instant/Chain | Medium |
| 4 | Drifter | Movement | Low |
| 5 | Double Value | Instant/State | Low |
| 6 | Time Slow | Timed/Game | Medium |
| 7 | Combo Starter | Timed/Stack | Medium |
| 8 | Vertical Line | Instant/Area | Medium |
| 9 | Horizontal Line | Instant/Area | Medium |

**Deferred:** Sticky Head, Risk/Reward orb (future packs)

---

### REQ-4: Effect Stacking & Duration Rules

**Source:** Q4

Effects shall stack with refreshed duration:

| Effect | Duration | Stack Behavior |
|--------|----------|----------------|
| Score Multiplier | 45s | Stack (2x + 2x = 4x) |
| Slow Fall | 45s | Stack (cap at 90% reduction) |
| Time Slow | 10s | Stack (cap at 0.25x speed) |
| Combo Starter | 10s | Refresh timer, increment count |
| Double Value | Until used | N/A (one-time state) |

---

### REQ-5: Spawn System - Weighted + Rarity Tiers

**Source:** Q5

The spawn system shall use weighted selection with rarity tiers:

**Rarity Distribution:**
| Rarity | Weight | Spawn Rate |
|--------|--------|------------|
| COMMON | 100 | ~50% |
| UNCOMMON | 40 | ~30% |
| RARE | 10 | ~10% |

**Orb Rarity Assignment:**
- COMMON: Blue, Red
- UNCOMMON: Score Multiplier, Slow Fall, Drifter, Double Value
- RARE: Half-Solid, Burst, Combo Starter, Time Slow, Vertical Line, Horizontal Line

---

### REQ-6: Migration Strategy - Big Bang

**Source:** Q6

Migration shall replace all existing orb systems in one refactor:

1. Implement new OrbData, OrbBehavior, Orb classes
2. Create OrbData resources for existing orbs (Blue, Red, Half-Solid)
3. Update OrbSpawner to use new system
4. Delete old scenes and scripts
5. Run all tests, fix issues
6. Manual gameplay verification

**Files to Delete:**
- `scripts/generic_orb.gd`, `blue_orb.gd`, `red_orb.gd`, `half_solid_orb.gd`, `orb_mngr.gd`
- `scenes/generic_orb.tscn`, `blue_orb.tscn`, `red_orb.tscn`, `half_solid_orb.tscn`

---

### REQ-7: Line Orb Scoring - Full Points

**Source:** Q7

When Vertical/Horizontal Line orbs collect other orbs, each collected orb shall award its full point value.

---

### REQ-8: Active Effects UI - Minimal (Deferred)

**Source:** Q8

No UI for active effects in this phase. Effects are visible through gameplay. Simple HUD indicators can be added in a follow-up pass.

---

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-1 | All orb logic must be unit-testable |
| NFR-2 | New orb types require only Resource files (no scripts) |
| NFR-3 | Effect stacking must be deterministic and documented |
| NFR-4 | Migration preserves existing score values and gameplay feel |
| NFR-5 | All changes validated via `./devscripts/test.sh` |

---

## Constraints

- Godot 4.4.1, GDScript, typed
- Keep diffs small and focused
- No large asset work (placeholder sprites acceptable)
- Preserve ball bounce mechanic unchanged
- 45 second effect duration (10s for time-altering effects)

---

## Success Criteria

- [ ] Unified Orb scene replaces all existing orb scenes
- [ ] 9 new orb types implemented and tested
- [ ] EffectManager handles all effect lifecycle
- [ ] Weighted spawn system with rarity tiers
- [ ] All tests pass
- [ ] Gameplay feels identical to before migration
