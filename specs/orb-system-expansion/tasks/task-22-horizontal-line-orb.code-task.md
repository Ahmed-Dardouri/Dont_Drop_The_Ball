---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create Horizontal Line Orb

## Description
Create the Horizontal Line orb resource that clears all orbs in the same horizontal row when collected.

## Background
The Horizontal Line orb is a RARE orb that uses LineClearBehavior to clear all orbs on the same Y-axis. This provides a strategic way to clear multiple orbs at once, complementary to the vertical variant.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `resources/orbs/horizontal_line_orb.tres`:
   - display_name = "Horizontal Line"
   - base_score = 5
   - rarity = RARE
   - behaviors = [
       ScoreBehavior(score_value=5),
       LineClearBehavior(direction=LineClearBehavior.LineDirection.HORIZONTAL, tolerance=20.0)
     ]
2. Ensure LineClearBehavior is configured for HORIZONTAL direction

## Dependencies
- Task 04: ScoreBehavior
- Task 13: LineClearBehavior

## Implementation Approach
1. **Create resource file**
   - Create .tres with LineClearBehavior configured for horizontal
2. **Test**
   - Test orbs on same Y are collected
   - Test orbs on different Y are not collected
3. **Manual demo**
   - Spawn orbs in row, collect line orb, watch row clear

## Acceptance Criteria

1. **Resource Loads**
   - Given horizontal_line_orb.tres
   - When loaded as OrbData
   - Then all properties are correct

2. **Clears Horizontal Line**
   - Given Horizontal Line orb collected
   - And other orbs at same Y position
   - Then all orbs in row are collected

3. **Respects Tolerance**
   - Given Horizontal Line orb collected
   - And orb at Y+25 (outside tolerance=20)
   - Then that orb is NOT collected

4. **Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all related tests pass

## Metadata
- **Complexity**: Low
- **Labels**: orb, line-clear
- **Required Skills**: GDScript, Godot Resources
