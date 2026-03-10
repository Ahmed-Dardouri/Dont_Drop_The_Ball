---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Create LineClearBehavior

## Description
Create the `LineClearBehavior` that clears all orbs in a vertical or horizontal line from the source orb position.

## Background
LineClearBehavior is used by Line orbs (vertical and horizontal variants). When collected, it finds all orbs on the same X-axis (horizontal) or Y-axis (vertical) within a tolerance and triggers their collection.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/line_clear_behavior.gd` extending OrbBehavior
2. Add enum for direction:
   ```gdscript
   enum LineDirection { VERTICAL, HORIZONTAL }
   ```
3. Add `@export` properties:
   - `var direction: LineDirection = LineDirection.VERTICAL`
   - `var tolerance: float = 20.0` (pixels of tolerance for alignment)
4. Implement `execute(context: Dictionary) -> void`:
   - Get source orb position from context
   - Find all Orb nodes in "orbs" group
   - For VERTICAL: find orbs where abs(orb.x - source.x) < tolerance
   - For HORIZONTAL: find orbs where abs(orb.y - source.y) < tolerance
   - Call `orb.collect()` on each matching orb (except self)

## Dependencies
- Task 02: OrbBehavior Abstract Base Class
- Task 05: Unified Orb Scene and Script (Orb must have "orbs" group)

## Implementation Approach
1. **TDD: Write failing test first**
   - Create `tests/unit/test_line_clear_behavior.gd`
   - Test vertical line clearing
   - Test horizontal line clearing
   - Test tolerance boundary
   - Test self exclusion
2. **Implement minimal code to pass**
   - Create LineClearBehavior class
   - Implement execute with line detection
3. **Refactor while keeping tests green**
   - Clean coordinate comparison logic

## Acceptance Criteria

1. **Vertical Line Clear**
   - Given LineClearBehavior with direction=VERTICAL
   - And orbs at same X position but different Y positions
   - When execute() is called
   - Then all orbs with matching X are collected

2. **Horizontal Line Clear**
   - Given LineClearBehavior with direction=HORIZONTAL
   - And orbs at same Y position but different X positions
   - When execute() is called
   - Then all orbs with matching Y are collected

3. **Tolerance Works**
   - Given LineClearBehavior with tolerance=20.0
   - And an orb at X+25 from source
   - When execute() is called
   - Then orb at X+25 is NOT collected

4. **Unit Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_line_clear_behavior.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, line-clear
- **Required Skills**: GDScript, Godot Scene Tree
