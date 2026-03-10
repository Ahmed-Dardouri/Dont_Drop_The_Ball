---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Drifter Orb

## Description
Create the Drifter orb resource that moves back and forth (oscillates) while on screen.

## Background
The Drifter orb is an UNCOMMON orb that uses MovementBehavior to oscillate horizontally. This makes it slightly harder to collect as it moves, but adds visual interest.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (see MovementBehavior bounds)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/drifter_orb.tres`:
   - display_name = "Drifter"
   - base_score = 2
   - rarity = UNCOMMON
   - behaviors = [
       ScoreBehavior(score_value=2),
       MovementBehavior(speed=50.0, oscillate=true, oscillate_distance=100.0)
     ]
2. Ensure MovementBehavior is properly configured for horizontal oscillation

## Dependencies
- Task 04: ScoreBehavior
- Task 11: MovementBehavior

## Implementation Approach
1. **Create resource file**
   - Create .tres with MovementBehavior configured
2. **Test**
   - Test orb oscillates
   - Test orb stays within bounds
3. **Manual demo**
   - Spawn orb, watch it oscillate, collect it

## Acceptance Criteria

1. **Resource Loads**
   - Given drifter_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Orb Oscillates**
   - Given a Drifter orb in scene
   - When time passes
   - Then orb moves back and forth horizontally

3. **Stays In Bounds**
   - Given a Drifter orb near screen edge
   - When oscillating
   - Then orb stays within viewport bounds

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb, movement
- **Required Skills**: GDScript, Godot Resources
