---
status: pending
created: 2026-03-10
started: null
completed: null
---
# Task: Integration Test - Gameplay Parity

## Description
Create integration tests to verify that the migrated orbs behave identically to the original implementation.

## Background
After migration to the new system, we need to verify gameplay parity - that the new resource-based orbs produce the same behavior as the old scripted orbs. This ensures no regression in core gameplay.

## Reference Documentation
**Required:**
- Design: specs/orb-system-expansion/design.md

**Additional References:**
- specs/orb-system-expansion/context.md (codebase patterns)
- specs/orb-system-expansion/plan.md (overall strategy)

**Note:** You MUST read the design document before beginning implementation.

## Technical Requirements
1. Create `tests/integration/test_orb_parity.gd`
2. Test cases:
   - Blue orb scores exactly 2 points
   - Red orb scores exactly 3 points
   - Half-solid orb reduces ball velocity to 1/3 on collision
   - Orbs expire and are freed after their lifespan
   - Orbs spawn at correct positions
   - Collision detection works correctly
3. Use GUT integration test patterns with scene instantiation

## Dependencies
- Task 08: Delete Old Files
- All previous tasks must be complete

## Implementation Approach
1. **TDD: Write test first**
   - Create test file with all parity test cases
   - Tests will fail until system is verified
2. **Run tests**
   - Verify all parity tests pass
3. **Manual verification**
   - Play game and compare feel to pre-migration

## Acceptance Criteria

1. **Blue Orb Scores 2**
   - Given a blue orb is collected
   - When score is checked
   - Then score increased by exactly 2

2. **Red Orb Scores 3**
   - Given a red orb is collected
   - When score is checked
   - Then score increased by exactly 3

3. **Half-Solid Reduces Velocity**
   - Given a ball collides with half-solid orb
   - When velocity is checked after collision
   - Then velocity equals original_velocity / 3

4. **Orb Expiration**
   - Given an orb with lifespan 30.0
   - When 30 seconds pass
   - Then orb is freed from scene

5. **Integration Tests Pass**
   - Given the implementation is complete
   - When running `./devscripts/test.sh`
   - Then all tests in test_orb_parity.gd pass

## Metadata
- **Complexity**: Medium
- **Labels**: testing, integration, parity
- **Required Skills**: GDScript, GUT Testing Framework
