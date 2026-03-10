# Orb System Expansion - Rough Idea

## Context
Existing Godot 4.4.1 GDScript game "Don't Drop the Ball" with core mechanic: player bounces an object using a semi-round head, and the object can deflect sideways.

The project has already gone through an initial refactor for modularity and testability.

This phase focuses on the orb system and the first major orb content expansion.

## Current State (Baseline)
- 3 orb types: BLUE, RED, HALF_SOLID
- OrbProps resource with Type field
- GenericOrb wrapper with child orb nodes
- OrbSpawner with timer-based spawning
- OrbManager handling collection events → score
- Tests for orb scoring and properties

## Main Objective
Create a modular, data-driven orb system that supports many orb behaviors cleanly, then plan and prepare the first major orb content pack.

## Orb System Requirements
Support for:
- Instant effects
- Timed effects
- Stack/refresh/replace rules
- Moving orbs
- Chain-reaction orbs
- Score/economy orbs
- Player-control and ball-control modifiers

## First Orb Content Pack
Aim for 6-10 new orb types, prioritizing fun, readability, and implementation efficiency.

### Suggested Directions
- Burst orb (clears nearby orbs, cashes them in)
- Vertical line orb
- Horizontal line orb
- Moving/drifter orb
- Slow fall orb
- Sticky head orb
- Combo starter orb
- Double value orb
- Slow motion orb
- One risk/reward orb

## Deliverables
1. Target orb architecture
2. Rules for effect lifetime, stacking, conflicts, state tracking
3. Exact first orb pack to implement and why
4. Implementation order from safest/core to most complex
5. What existing systems need adaptation
6. Tests for each orb type or orb family
7. Acceptance criteria for each implementation task
8. Manual verification steps for each orb
9. Risks and fallback options

## Constraints
- Keep existing gameplay intact
- Prefer typed GDScript
- Keep diffs small and focused
- Avoid large asset work
- Validate all work through ./devscripts/test.sh
- Do not implement monetization or heavy progression in this phase
