---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Implement LineClearBehavior

## Description
Implement the LineClearBehavior class that clears collectible orbs in a vertical or horizontal line and cashes them in.

## Background
Line clear orbs are a new orb type that, when collected, find all orbs in a vertical column or horizontal row (within a configurable width) and collect them. This supports both vertical and horizontal directions.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.4 - LineClearBehavior)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 5)
- scripts/data/behaviors/orb_behavior.gd (base class)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/line_clear_behavior.gd`
2. Extend OrbBehavior class
3. Properties:
   - `enum Direction { VERTICAL, HORIZONTAL }`
   - `@export var direction: Direction = Direction.VERTICAL`
   - `@export var line_width: float = 50.0`
   - `@export var score_multiplier: float = 1.0`
4. Implement `execute(context: Dictionary) -> void`:
   - Get orb position from context
   - Find all orbs in "orbs" group within line bounds
   - Exclude self from collection
   - Call `OrbBehavior.collect_orb()` for each target
   - Sum total score and call `AddScoreEvent.invoke(total_score)`
5. Implement `_find_orbs_in_line(center: Vector2, dir: Direction, width: float) -> Array[Node]`

## Dependencies
- task-03-chain-collection-helper (requires collect_orb static function)

## Implementation Approach
1. TDD: Write test_vertical_line_detects_orbs
2. TDD: Write test_horizontal_line_detects_orbs
3. TDD: Write test_line_width_respected
4. TDD: Write test_self_excluded
5. Implement LineClearBehavior to pass all tests

## Acceptance Criteria

1. **Vertical Line Detection**
   - Given an orb at position (100, 200)
   - And other orbs at (95, 100), (105, 300), (200, 200)
   - And direction = VERTICAL, line_width = 50
   - When execute() is called
   - Then orbs at (95, 100) and (105, 300) are collected (within x tolerance)
   - And orb at (200, 200) is NOT collected (outside x tolerance)

2. **Horizontal Line Detection**
   - Given an orb at position (100, 200)
   - And other orbs at (50, 195), (150, 205), (100, 400)
   - And direction = HORIZONTAL, line_width = 50
   - When execute() is called
   - Then orbs at (50, 195) and (150, 205) are collected (within y tolerance)
   - And orb at (100, 400) is NOT collected (outside y tolerance)

3. **Line Width Respected**
   - Given line_width = 30
   - And an orb at x = 100 (center) + 35 (outside width)
   - When execute() is called with VERTICAL direction
   - Then the orb at x=135 is NOT collected

4. **Self Excluded**
   - Given an orb with LineClearBehavior
   - When execute() is called
   - Then the triggering orb is NOT collected

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests in test_line_clear_behavior.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, line-clear, chain-reaction
- **Required Skills**: GDScript, coordinate math, enums
