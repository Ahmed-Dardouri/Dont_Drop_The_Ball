# Orb Content Pack - Rough Idea

## Source
From design.start event on 2026-03-10.

## Objective
Implement a first real content pack of 8 new orb types on top of the existing orb/effect system.

## Constraints
- Do NOT do more broad refactoring
- Preserve current core gameplay feel
- Keep player bouncing mechanic unchanged
- Prefer typed GDScript
- Validate with ./devscripts/test.sh (must exit 0)
- Add/update GUT tests for deterministic logic

## Orb Types to Implement
1. **Burst Orb** - Clears nearby collectible orbs in a radius
2. **Vertical Line Orb** - Clears orbs in a vertical line through position
3. **Horizontal Line Orb** - Clears orbs in a horizontal line through position
4. **Slow Fall Orb** - Temporarily reduces ball's falling speed/gravity
5. **Sticky Head Orb** - Ball sticks briefly to player's head before bouncing
6. **Double Value Orb** - Temporarily doubles score from pickups
7. **Combo Starter Orb** - Starts or boosts a combo/multiplier window
8. **Drifter Orb** - Moving orb that drifts in a simple readable pattern

## Existing Context
- Tasks 01-03 (OrbData, OrbBehavior, EffectManager) already completed
- 24-task implementation plan exists in specs/orb-system-expansion/
- EffectManager already has: score_multiplier, slow_fall, time_slow, combo_chain, double_value effects
