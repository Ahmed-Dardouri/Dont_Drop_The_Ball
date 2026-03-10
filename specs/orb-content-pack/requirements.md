# Orb Content Pack - Requirements

## Overview

Implement a first real content pack of 8 new orb types on top of the existing orb/effect system. This is NOT an architecture task - it uses the existing OrbData/OrbBehavior/EffectManager systems.

---

## Consolidated Requirements (from Q&A)

### REQ-1: Sticky Head Orb - Collision Dampening

**Source:** Q1/A1, Q4/A4

The Sticky Head Orb shall use collision-based dampening:

| Property | Value |
|----------|-------|
| Behavior Type | Collision dampening |
| Duration | 15-20 seconds (configurable) |
| Effect ID | `sticky_head` |
| Effect Value | 0.5 (50% bounce velocity) |
| Trigger | On player collision (via `_on_body_entered`) |
| Mechanism | Reduces ball's vertical velocity when bouncing off player |
| Stacking | Replace (single instance) |

**Implementation:**
- Ball detects player collision in `_on_body_entered(body)`
- If `sticky_head` effect active, apply dampening to `linear_velocity.y`
- Effect lasts for duration, applies to ALL bounces during that time

**Rationale:**
- Ball is RigidBody2D - collision detection is natural
- Different from Slow Fall Orb (which affects gravity, not bounce)
- Integrates cleanly with existing EffectManager pattern
- Preserves core bounce mechanic feel
- Simple, testable, no physics glitches

---

### REQ-2: Drifter Orb - Horizontal Drift Movement

**Source:** Q2/A2

The Drifter Orb shall use a horizontal oscillation pattern:

| Property | Value |
|----------|-------|
| Movement Pattern | Horizontal oscillation (sine wave) |
| Formula | `position.x = initial_x + sin(time * speed) * amplitude` |
| Amplitude | 50-100 pixels (configurable) |
| Speed | 1-2 cycles/second (configurable) |
| Behavior Type | MovementBehavior using `process()` |
| Boundary Handling | Stay within spawn zone |

**Rationale:**
- Most readable pattern for players
- Least disruptive to vertical gameplay focus
- Stays within spawn zone bounds
- Simplest implementation using existing OrbBehavior pattern

---

### REQ-3: Line Orbs - Full-screen Sweep with Tolerance

**Source:** Q3/A3

The Vertical/Horizontal Line Orbs shall use full-screen sweep with coordinate tolerance:

| Property | Value |
|----------|-------|
| Line Definition | Coordinate tolerance matching |
| Tolerance | 20 pixels (configurable) |
| Range | Full scene (all matching orbs) |
| Max Orbs Cleared | No limit |
| Visual Effect | None (MVP) |
| Self Consumed | YES (standard collection) |

**Matching Logic:**
- **Vertical Line**: Clear orbs where `abs(orb.x - source.x) < tolerance`
- **Horizontal Line**: Clear orbs where `abs(orb.y - source.y) < tolerance`

**Rationale:**
- Matches existing task-13 design for LineClearBehavior
- Simplest implementation using standard scene tree queries
- Dramatic "power move" feel for special orbs
- Predictable for players (visible alignment = cleared)

---

### REQ-4: Burst Orb - Radius-based Chain Reaction

**Source:** Design Decision (no question needed - straightforward)

The Burst Orb shall use radius-based chain reaction:

| Property | Value |
|----------|-------|
| Detection Method | Distance from source orb position |
| Radius | 150 pixels (configurable) |
| Max Orbs Cleared | No limit |
| Self Consumed | YES (standard collection) |
| Chain Reaction | All orbs within radius are collected |

**Rationale:**
- Matches existing task-12 design for ChainReactionBehavior
- 150px provides meaningful area coverage without being overpowered
- Standard `get_tree().get_nodes_in_group("orbs")` pattern
- Simple distance check: `orb.position.distance_to(source.position) < radius`

---

## Requirements Complete

All orb types now have defined specifications:

| Orb Type | Requirement | Status |
|----------|-------------|--------|
| Sticky Head Orb | REQ-1 | Defined |
| Drifter Orb | REQ-2 | Defined |
| Line Orbs (V/H) | REQ-3 | Defined |
| Burst Orb | REQ-4 | Defined |
| Slow Fall Orb | Existing | EffectManager: `slow_fall` |
| Double Value Orb | Existing | EffectManager: `double_value` |
| Combo Starter Orb | Existing | EffectManager: `combo_chain` |

---

## Orb Types to Implement

| # | Orb Name | Effect Type | Complexity | Notes |
|---|----------|-------------|------------|-------|
| 1 | Burst Orb | Instant/Chain | Medium | Clears nearby orbs in radius |
| 2 | Vertical Line Orb | Instant/Area | Medium | Clears orbs in vertical line |
| 3 | Horizontal Line Orb | Instant/Area | Medium | Clears orbs in horizontal line |
| 4 | Slow Fall Orb | Timed | Low-Med | Already in EffectManager |
| 5 | Sticky Head Orb | Timed | Medium | NEW: damping-zone approach |
| 6 | Double Value Orb | Timed/State | Low | Already in EffectManager |
| 7 | Combo Starter Orb | Timed/Stack | Medium | Already in EffectManager |
| 8 | Drifter Orb | Movement | Low | MovementBehavior |

---

## Constraints

- Do NOT do more broad refactoring
- Preserve current core gameplay feel
- Keep player bouncing mechanic unchanged
- Prefer typed GDScript
- Validate with `./devscripts/test.sh` (must exit 0)
- Add/update GUT tests for deterministic logic

---

## Success Criteria

- [ ] All 8 orb types implemented in game codebase
- [ ] Integrated into spawning/content definitions
- [ ] `./devscripts/test.sh` exits 0
- [ ] Existing gameplay not unintentionally broken
- [ ] Final summary includes: files changed, tests added, behavior descriptions, manual verification steps
