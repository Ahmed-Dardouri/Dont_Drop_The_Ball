---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Implement BurstBehavior

## Description
Implement the BurstBehavior class that clears nearby collectible orbs in a radius and cashes them in for the player.

## Background
Burst orbs are a new orb type that, when collected, find all orbs within a configurable radius and collect them, awarding score for each. This uses the collect_orb() helper from task-03.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md (Section 3.4 - BurstBehavior)

**Additional References:**
- specs/orb-system-expansion/plan.md (Step 4)
- scripts/data/behaviors/orb_behavior.gd (base class)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `scripts/data/behaviors/burst_behavior.gd`
2. Extend OrbBehavior class
3. Properties:
   - `@export var radius: float = 150.0`
   - `@export var score_multiplier: float = 1.0`
4. Implement `execute(context: Dictionary) -> void`:
   - Get orb position from context
   - Find all orbs in "orbs" group within radius
   - Exclude self from collection
   - Call `OrbBehavior.collect_orb()` for each target
   - Sum total score and call `AddScoreEvent.invoke(total_score)`
5. Implement `_find_orbs_in_radius(center: Vector2, radius: float) -> Array[Node]`

## Dependencies
- task-03-chain-collection-helper (requires collect_orb static function)

## Implementation Approach
1. TDD: Write test_no_orbs_nearby_returns_zero_score
2. TDD: Write test_orbs_in_radius_are_collected
3. TDD: Write test_self_not_collected
4. TDD: Write test_score_multiplier_applied
5. Implement BurstBehavior to pass all tests

## Acceptance Criteria

1. **No Orbs Nearby**
   - Given an orb with BurstBehavior at position (100, 100)
   - And no other orbs within 150 pixels
   - When execute() is called
   - Then no score is awarded
   - And no orbs are freed

2. **Orbs in Radius Collected**
   - Given an orb with BurstBehavior at position (100, 100)
   - And 3 other orbs within 150 pixels (at 50, 80, 120 pixel distances)
   - When execute() is called
   - Then all 3 nearby orbs are freed
   - And score is awarded for each

3. **Self Not Collected**
   - Given an orb with BurstBehavior
   - When execute() is called
   - Then the triggering orb is NOT collected by its own burst

4. **Score Multiplier Applied**
   - Given nearby orbs worth 30 total base score
   - And score_multiplier = 2.0
   - When execute() is called
   - Then 60 score is awarded via AddScoreEvent

5. **Unit Tests Pass**
   - Given the implementation is complete
   - When running the test suite
   - Then all tests in test_burst_behavior.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: behavior, burst, chain-reaction
- **Required Skills**: GDScript, Godot node groups, distance calculations
