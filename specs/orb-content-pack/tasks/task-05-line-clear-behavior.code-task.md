---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: LineClearBehavior Implementation

## Description
Implement the LineClearBehavior class for Vertical and Horizontal Line Orbs. When executed, it clears all orbs aligned with the source orb along a vertical or horizontal line within a configurable tolerance.

## Background
Line Orbs clear collectible orbs in a line through their position. Vertical Line Orbs clear orbs with similar X coordinates, Horizontal Line Orbs clear orbs with similar Y coordinates. The tolerance defines how close coordinates must be to match.

## Reference Documentation
**Required:**
- Design: specs/orb-content-pack/design.md (Section 4.2)
- Plan: specs/orb-content-pack/plan.md (Step 5)

**Additional References:**
- scripts/data/behaviors/orb_behavior.gd (base class)
- Existing orb node structure

## Technical Requirements
1. Create `scripts/data/behaviors/line_clear_behavior.gd` extending OrbBehavior
2. Define enum `LineDirection` with VERTICAL and HORIZONTAL values
3. Export `direction: LineDirection` with default VERTICAL
4. Export `tolerance: float` with default 20.0
5. In `execute()`: match orbs based on direction:
   - VERTICAL: `abs(orb_pos.x - source_pos.x) < tolerance`
   - HORIZONTAL: `abs(orb_pos.y - source_pos.y) < tolerance`
6. Skip source orb and orbs not in tree
7. Call `collect()` on matching orbs

## Dependencies
- scripts/data/behaviors/orb_behavior.gd (base class)
- Orbs must be in "orbs" group
- Orbs must have `collect()` method

## Implementation Approach
1. **TDD: Write failing tests first**
   - Create `tests/unit/test_line_clear_behavior.gd`
   - Test vertical_clear
   - Test horizontal_clear
   - Test tolerance_respected
   - Test self_excluded
2. **Implement minimal code to pass**
   - Create LineClearBehavior with direction enum and tolerance logic
3. **Refactor while keeping tests green**
   - Ensure match statement handles both directions correctly

## Acceptance Criteria

1. **Vertical Clear**
   - Given 3 orbs with X coordinate within 20px of source
   - When execute(VERTICAL) is called
   - Then 3 aligned orbs are collected

2. **Horizontal Clear**
   - Given 3 orbs with Y coordinate within 20px of source
   - When execute(HORIZONTAL) is called
   - Then 3 aligned orbs are collected

3. **Tolerance Respected**
   - Given an orb at 25px offset with tolerance=20
   - When execute() is called
   - Then the orb is NOT collected

4. **Self Excluded**
   - Given source orb is on the line
   - When execute() is called
   - Then source orb is NOT collected

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all 4 tests pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, line-clear, vertical, horizontal, tolerance
- **Required Skills**: GDScript, Godot scene tree, coordinate math
