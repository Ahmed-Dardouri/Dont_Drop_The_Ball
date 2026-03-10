---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Burst Orb

## Description
Create the Burst orb resource that collects all nearby orbs in a 150-pixel radius when collected.

## Background
The Burst orb is a RARE orb that uses ChainReactionBehavior to trigger a chain reaction. When collected, it finds all orbs within 150 pixels and collects them too, creating a burst effect.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/burst_orb.tres`:
   - display_name = "Burst"
   - base_score = 8
   - rarity = RARE
   - behaviors = [
       ScoreBehavior(score_value=8),
       ChainReactionBehavior(radius=150.0)
     ]
2. Ensure ChainReactionBehavior is configured with correct radius

## Dependencies
- Task 04: ScoreBehavior
- Task 12: ChainReactionBehavior

## Implementation Approach
1. **Create resource file**
   - Create .tres with ChainReactionBehavior configured
2. **Test**
   - Test orbs within radius are collected
   - Test orbs outside radius are not collected
3. **Manual demo**
   - Spawn orb cluster, collect burst orb, watch chain reaction

## Acceptance Criteria

1. **Resource Loads**
   - Given burst_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Collects Nearby Orbs**
   - Given Burst orb collected
   - And other orbs within 150 pixels
   - Then all nearby orbs are also collected

3. **Respects Radius**
   - Given Burst orb collected
   - And orb at 200 pixels distance
   - Then that orb is NOT collected

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb, chain-reaction
- **Required Skills**: GDScript, Godot Resources
